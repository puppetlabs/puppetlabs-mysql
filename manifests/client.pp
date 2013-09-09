#
class mysql::client (
  $bindings_enable = false,
) inherits mysql::globals {

  include '::mysql::client::install'

  if $bindings_enable {
    include '::mysql::bindings'
  }

}
