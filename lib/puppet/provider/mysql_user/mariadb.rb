Puppet::Type.type(:mysql_user).provide(:mariadb, :parent => 'mysql') do

  desc 'manage users for a mariadb database.'

  confine :feature => :long_usernames

  confine :true => version_check('10.0.0-MariaDB')

end
