file { '/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo':
  source => 'https://raw.githubusercontent.com/sclorg/centos-release-scl/master/centos-release-scl/RPM-GPG-KEY-CentOS-SIG-SCLo',
}

yumrepo { 'centos-sclo-rh':
  ensure     => present,
  name       => 'CentOS-SCLo-scl-rh',
  enabled    => true,
  baseurl    => 'http://mirror.centos.org/centos/7/sclo/$basearch/rh/',
  mirrorlist => 'http://mirrorlist.centos.org?arch=$basearch&release=7&repo=sclo-rh',
  descr      => 'CentOS-7 - SCLo rh',
  gpgcheck   => true,
  gpgkey     => 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-SCLo',
}
class { 'mysql::server':
  package_name   => 'rh-mysql80',
  package_ensure => 'installed',
  service_name   => 'rh-mysql80-mysqld',
  config_file    => '/etc/my.cnf',
  includedir     => '/etc/my.cnf.d',
  options        => { mysqld => { log_error => '/var/log/mysqld.log', datadir => '/var/lib/mysql' } },
}
