

default['appdynamics']['controller']['fqdn']= "dc1-qe-appdynamics-01"

default['appdynamics']['controller']['data_dir'] = "/var/appdynamics"
default['appdynamics']['controller']['software_dir'] = "/opt/appdynamics"

default['appdynamics']['controller']['port']="8090"
default['appdynamics']['controller']['ssl_port']="443"
default['appdynamics']['controller']['version']="4.1"

default['appdynamics']['user']="appdynamics"
default['appdynamics']['group']="appdynamics"


default['appdynamics']['controller'] = {
	'dir' => "/var/appdynamics",
	'port' => '8090',
	'ssl_port' => '443',
	'version' => '4.1',
	'install' => {
	  'url' => 'http://www.appdynamics.com/storeofflocally',
	  'sha' => '034bf139708c074150d78cc66478df5dd2f94c84193b94ff22459d2504d8bb1c',
	  'license_url' => 'mylicensefile'
	}
}

