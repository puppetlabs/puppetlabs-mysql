require File.expand_path(File.join(File.dirname(__FILE__), '..', 'noop'))
Puppet::Type.type(:mysql_user).provide(:noop, :parent => Puppet::Provider::Noop)
