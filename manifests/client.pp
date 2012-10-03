class mysql::client (
) inherits mysql {
  case $software_package {
    ius: {
      if $::osfamily == 'RedHat' {
        # Use yum shell to remove various distro packages, install IUS packages in a single yum transaction so as to avoid problems with dependencies/conflicts
        $installs = $mysql::params::ius_client_packages
        $excludes = $mysql::params::ius_client_package_excludes
      } else {
        fail("IUScommunity packaging is only for RedHat-family systems")
      }
    }
    default,distro,vendor: {
      $installs = [$mysql::params::client_package_name]
      $excludes = [$ius_client_packages]
    }
  }
  exec { 'yum-shell-mysql':
    command => "yum -y shell /tmp/yum-shell-mysql",
  }
  file { '/tmp/yum-shell-mysql':
    content => template("mysql/yum-shell-mysql.erb")
  }
  File['/tmp/yum-shell-mysql'] -> Exec['yum-shell-mysql']

}
