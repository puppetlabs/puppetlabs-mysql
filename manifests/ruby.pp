#installs the ruby bindings for mysql
class mysql::ruby {
  # I am not making the mysql package a dep for this
  # the only dep is the package which yum will resolve for me.
  #case $operatingsystem {
  #  'debian', 'ubuntu' : {$ruby_mysql_name = 'libmysql-ruby'}
  #  default: {$ruby_mysql_name = 'ruby-mysql'}
  #}

  package{'ruby-mysql':
  #  name => $ruby_mysql_name,
    provider => 'gem',
    ensure   => installed,
  }
}
