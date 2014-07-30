Puppet::Type.type(:mysql_grant).provide(:mariadb, :parent => 'mysql') do

  desc 'Set grants for users in MariaDB.'

  confine :feature => :long_usernames

  confine :true => version_check('10.0.0-MariaDB')

end
