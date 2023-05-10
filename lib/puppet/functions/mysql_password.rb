# frozen_string_literal: true

# @summary DEPRECATED. Use the namespaced function [`mysql::password`](#mysqlpassword) instead.
Puppet::Functions.create_function(:mysql_password) do
  # @param password
  #   Plain text password.
  # @param sensitive
  #   If the mysql password hash should be of datatype Sensitive[String]
  #
  # @return
  #   The mysql password hash from the 4.x function mysql::password.
  dispatch :mysql_password do
    required_param 'Variant[String, Sensitive[String]]', :password
    optional_param 'Boolean', :sensitive
    return_type 'Variant[String, Sensitive[String]]'
  end

  def mysql_password(password, sensitive = false) # rubocop:disable Style/OptionalBooleanParameter
    call_function('deprecation', 'mysql_password', "This method has been deprecated, please use the namespaced version 'mysql::password' instead.")
    call_function('mysql::password', password, sensitive)
  end
end
