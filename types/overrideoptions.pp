# @summary A hash of options to merge with the default options.  Sections and keys can be knocked
#   out of the final config file by setting their value to `undef`.
type Mysql::OverrideOptions = Hash[
  String,
  Optional[Hash],
]
