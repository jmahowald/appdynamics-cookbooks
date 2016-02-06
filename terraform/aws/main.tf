
#TODO move this to distributed repo itself
resource "aws_instance" "appdynamics" {
  ami = "${var.ami}"
  instance_type = "${var.instance_type}"
  subnet_id = "${var.subnet_id}"
  #This should release all the resources, like the associated EBS volume
  instance_initiated_shutdown_behavior = "terminate"

  # TODO allow for multiple security security_groups
  # but since they need to be joined/split for parameters
  # right now, a single security group will suffice
  security_groups = ["${split(",", var.security_group_ids)}"]

  key_name = "${var.key_name}"

  #TODO look into why the heck I think I needed this flag 
  source_dest_check = false
   tags = { 
    Name = "${var.chef_node_name} "
    Owner = "${var.owner}"
  }
  connection {
    user =  "${var.image_user}"
    #    https://github.com/hashicorp/terraform/issues/2563
    #    Shouldn't need to specify this but issue above
    agent = "false"
    key_file = "${var.ssh_keypath}"
  }

  ebs_block_device {
    device_name = "/dev/sdb"
    # I wish terraform had if logic so that I could
    # EITHER use a snapshot id or specify the rest
    #snapshot_id = "${var.snapshot_id}"

    volume_size = "${var.volume_size_gb}"
    volume_type = "gp2"
    delete_on_termination = true
  }


  provisioner "local-exec" {
    command = "KNIFE_HOME=`pwd`/.chef make -C ${path.module} upload"
  } 


  ebs_block_device {
    device_name = "/dev/sdb"
    # I wish terraform had if logic so that I could
    # EITHER use a snapshot id or specify the rest
    #snapshot_id = "${var.snapshot_id}"

    volume_size = "${var.volume_size_gb}"
    volume_type = "gp2"
    delete_on_termination = true
  }


  provisioner "remote-exec" {
    inline = [
    #No idea why I can't specify /xvdb for instance_type
    #but specify /dev/sdb gets renamed
    #it's a kernel level thing
    #http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ebs-using-volumes.html
    #Ideally I could use variable interpolation
      
    #If you are making a brand new non snapshotted volume then
    #you need to run mkfs.  Don't run that if you are using a snapshot
      "sudo mkfs -t ext4  /dev/xvdb",
      "sudo mkdir ${var.appdynamics_data_dir}",
      "sudo mount /dev/xvdb ${var.appdynamics_data_dir}"
    ]
  }


  #TODO this is a hack because of https://github.com/hashicorp/terraform/issues/649
  #If we rerun we want to recreate the chef client
  #Also why not put this in the Makefile.  (Cause it feels wrong, that's why)
  provisioner "local-exec" {
    command = "knife client delete -y ${var.chef_node_name} || echo 'chef client already dead'"
  }

  #TODO this is a hack because of https://github.com/hashicorp/terraform/issues/649
  #If we rerun we want to recreate the chef client
  #Also why not put this in the Makefile.  (Cause it feels wrong, that's why)
  provisioner "local-exec" {
    command = "knife node delete -y ${var.chef_node_name} || echo 'chef node already dead'"
  }
    provisioner "chef"  {
        attributes {
          "gen_naming" {
            "service_defs"{
              "appdynamics" {
                "port" = 80
              }
            }
          }
          "appdynamics" {
            "controller" {
              "fqdn" = "appdynamics.service.consul"
              "password" = "${var.appdynamics_password}"
              "data_dir" = "${var.appdynamics_data_dir}"
              #Interestingly, even though this has a defualt value in the
              #attributes, it doesn't merge in for some reason,
              #thus we need to specify it here specifically
              "software_dir" = "/opt/appdynamics"
              "install" {
                "url" = "http://repos.service.consul/tarballs/controller_64bit_linux.sh"
                "license_url" = "http://repos.service.consul/tarballs/appdynamics.lic"
              }
            }
          }
        }

        #TODO now have soft dependency on the naming service, and because of 
        #https://github.com/hashicorp/terraform/issues/1178
        #we can't resolve with a module level depends_on
        run_list = [
         "gen_naming::service_defs",
         "iptables::disabled"]
        

        node_name = "${var.chef_node_name}"
        server_url = "${var.chef_server_url}"
        validation_client_name = "${var.chef_validator_name}"
        validation_key_path = "${var.chef_validator_path}"
        version = "${var.chef_version}"
        ssl_verify_mode = ":verify_none"
    }

  #Because name server changes durign the run of the ruby process, it may
  #have cached the name server, so we do second run for the 
  provisioner "local-exec" {
    command = <<EOT
    knife node run_list add ${var.chef_node_name} \
    recipe[appdynamics::controller]
EOT
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chef-client"
    ]
  }
}

output "controller_ip" {
  value = "${aws_instance.appdynamics.private_ip}"
}
