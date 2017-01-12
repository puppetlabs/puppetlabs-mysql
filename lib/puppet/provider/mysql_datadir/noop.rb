require File.expand_path(File.join(File.dirname(__FILE__), '..', 'noop'))
Puppet::Type.type(:mysql_datadir).provide(:noop, :parent => Puppet::Provider::Noop)
