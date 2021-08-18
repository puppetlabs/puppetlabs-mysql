# @summary A hash of options structured like the override_options, but not merged with the default options.
# Use this if you don’t want your options merged with the default options.
type Mysql::Options = Hash[
  String,
  Hash,
]
