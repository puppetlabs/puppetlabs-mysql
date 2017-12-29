require 'digest/sha1'
# Returns the mysql password hash from the clear text password.
# Hash a string as mysql's "PASSWORD()" function would do it
Puppet::Functions.create_function(:'mysql::password') do
  dispatch :password do
    required_param 'String', :password
    return_type 'String'
  end

  def password(password)
    return '' if password.empty?
    return password if password =~ %r{\*[A-F0-9]{40}$}
    '*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(password)).upcase
  end
end
