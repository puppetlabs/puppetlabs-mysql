# hash a string as mysql's "PASSWORD()" function would do it
require 'digest/sha1'

module Puppet::Parser::Functions
	newfunction(:mysql_password, :type => :rvalue) do |args|
		'*' + Digest::SHA1.hexdigest(Digest::SHA1.digest(args[0])).upcase
	end
end

