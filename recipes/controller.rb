# automation of http://docs.appdynamics.com/pages/viewpage.action?pageId=3212836


#Generate's a secure_password
# include Opscode:'OpenSSL':'Password'
# 
# set_unless['appynamics']['controller']['password'] = secure_password
#Used in the config var file





group node['appdynamics']['group']
user node['appdynamics']['user'] do
  group node['appdynamics']['group']
end



directory node['appdynamics']['controller']['data_dir']  do
  owner  node['appdynamics']['user']
end

directory node['appdynamics']['controller']['software_dir'] do
  owner  node['appdynamics']['user']
  recursive true
end

#Set the rootUser password and the mysql password to be the
#same unless they are already set.
controller_pwd = node[:appdynamics][:controller][:password]
if(!node['appdynamics']['controller']['mysql_root_password'])
  node.set['appdynamics']['controller']['mysql_root_password'] = controller_pwd
end
if(!node['appdynamics']['controller']['root_user_password'])
  node.set['appdynamics']['controller']['root_user_password'] = controller_pwd
end



#required by install script
package "libaio"

#This is a self contained installed
remote_file "/usr/local/src/controller_64bit_linux_v#{node['appdynamics']['controller']['version']}.sh" do
  source node['appdynamics']['controller']['install']['url']
  checksum node['appdynamics']['controller']['install']['sha']
  mode "0755"
end

template "/tmp/controllerinstaller.var" do
  source "controllerinstaller.var.erb"
  owner "appdynamics"
end
# TODO should be sharing this in a var with the remote file 
execute "install_appdynamics_controller"  do   
  creates "#{node['appdynamics']['controller']['software_dir']}/bin/controller.sh"
  command "/usr/local/src/controller_64bit_linux_v#{node['appdynamics']['controller']['version']}.sh -q -varfile /tmp/controllerinstaller.var"
  user "appdynamics"
end


remote_file "#{node['appdynamics']['controller']['software_dir']}/license.lic" do
  source node['appdynamics']['controller']['install']['license_url']
  owner node['appdynamics']['user']
  mode 0644
end