# See README.md.
class mysql::client::install {

  if $mysql::client::package_manage {
		if $::osfamily == 'Windows' {  
			include mysql::server::install
		} else {
			package { 'mysql_client':
				ensure =>          $mysql::client::package_ensure,
        install_options => $mysql::client::install_options,
				name   =>          $mysql::client::package_name,
			}  
		}
  }
}
