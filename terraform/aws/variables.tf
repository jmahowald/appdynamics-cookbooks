variable "ami" {}
variable "image_user" {}
variable "subnet_id" {}
variable "instance_type" {
	default = "t2.medium"
}
variable "security_group_ids" {}
variable "chef_server_url" {}
variable "chef_version" {
	default =  "12.4.1"
}
variable "chef_validator_name" {}
variable "chef_validator_path" {}

variable "volume_size_gb" {
	default = "20"
}

variable "owner" {}
variable "key_name" {}
variable "ssh_keypath" {}
variable "chef_node_name" {
	default = "appdynamics"
}

variable "appdynamics_data_dir" {
	default = "/var/appdynamics"
}
variable "appdynamics_password" {
	default = "PAssw0rd"
}
