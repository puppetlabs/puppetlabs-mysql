#
class mysql::server::providers {
  create_resources('mysql_user', $mysql::server::users)
  create_resources('mysql_grant', $mysql::server::grants)
  create_resources('mysql_database', $mysql::server::databases)
}
