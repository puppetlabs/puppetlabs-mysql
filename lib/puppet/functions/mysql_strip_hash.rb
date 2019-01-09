# @summary
#   A wrapper for the 4.x function 'mysql::strip_hash' to bridge the gap between
#     it and the 3.x function 'mysql_strip_hash'.
#
Puppet::Functions.create_function(:mysql_strip_hash) do
  # @param hash
  #   Hash to be stripped
  #
  # @return hash 
  #   The given hash with all blank entries removed
  #
  dispatch :mysql_strip_hash do
    required_param 'Hash', :hash
    return_type 'Hash'
  end

  def mysql_strip_hash(hash)
    call_function('deprecation', 'mysql_strip_hash', "This method has been deprecated, please use the namespaced version 'mysql::strip_hash' instead.")
    call_function('mysql::strip_hash', hash)
  end
end
