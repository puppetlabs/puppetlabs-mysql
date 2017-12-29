# Returns the dirname of a path.
Puppet::Functions.create_function(:'mysql::dirname') do
  dispatch :dirname do
    required_param 'Variant[String, Undef]', :path
    return_type 'String'
  end

  def dirname(path)
    return '' if path.nil?
    File.dirname(path)
  end
end
