Puppet::Type.type(:mysql_user).provide(:mariadb, :parent => 'mysql') do

  desc 'manage users for a mariadb database.'

  commands :mysql => 'mysql'

  # if we actually *can* find mysql in the path, we check the version, and
  # based on that, we confine. The following code is based on the rpm/yum providers
  if command('mysql')
    confine :true => begin
    product_version = mysql('--version')
    rescue Puppet::ExecutionFailure
      false
    else
      true if /10\.\d+.\d+-MariaDB/.match(product_version)
    end
  end

end
