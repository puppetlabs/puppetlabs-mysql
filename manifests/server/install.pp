#
class mysql::server::install {

  if $mysql::server::package_manage {
		if $::osfamily == 'Windows' { 
			# You might have to install Chocolatey manually before this works.
			package { 'mysql-server':
				ensure => $mysql::server::package_ensure,
				install_options => $mysql::server::install_options,
				name   => $mysql::server::package_name,
				provider => 'chocolatey',
			} 
		} else {
			package { 'mysql-server':
				ensure => $mysql::server::package_ensure,
				install_options => $mysql::server::install_options,
				name   => $mysql::server::package_name,
			}
		}
	}
}
