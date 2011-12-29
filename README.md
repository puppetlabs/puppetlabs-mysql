Mysql
=====

This module has evolved and is originally based on work by David Schmitt.  If
anyone else was involved in the development of this module and wants credit,
let Puppetlabs know.

The mysql module is composed of classes, defined types, and custom
types/providers

Classes
-------

* mysql         - Manages the mysql client package
* mysql::python - Manages the python bindings
* mysql::ruby   - Manages the ruby bindings (Automatically declared with
  mysql::server) 
* mysql::server - Manages a mysql server includeing packages, configs, and
  services

*Parameters*

The mysql server class provides the following optional parameters:

* service\_name - Name of the mysql server service. Defaults to OS specific
  value
* package\_name - Name of the mysql server package. Defaults to OS specific
  value
* config\_hash  - Takes a hash of server configuration values to built the
  my.cnf file(s)

*Available keys for config_hash*

* root\_password - If the root mysql user should have a password, set it with
  this key. *This stores the password in PLAIN TEXT in /root/.my.cnf*
* bind\_address  - The address the mysql server should bind on.  Defaults to
  127.0.0.1 
* port - The port to listen on.  Defaults to 3306
* etc\_root\_password - Whether to store the root password in /etc/my.cnf.
  Defaults to false
  
*Example*

```puppet 
class { 'mysql::server': 
  config_hash => { 'root_password' => 'foo' } 
} 
``` 

Defined Types
-------------

* mysql::db - Manages a database

*Parameters*

* user - A user to manage along with the database
* password - The user's password (not the mysql hash)
* charset  - The character set for a database. Only set during DB creation
* host - Host for assigning privileges to user
* grant - Grant privileges for user. Takes an array
* sql - SQL commands to inject in the database
* enforce_sql - If true, the value of `sql` will always be enforced on the database

*Example*

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['all'],
}
```

Types/Providers
---------

*Types*

* database - Manages databases
* database_grant - Manages grant rules globally or per database
* database_user - Manages global users

*Providers*

* mysql

For more information on the included types, the puppet describe command is available

`puppet describe database`

`puppet describe database_grant`

`puppet describe database_user`

*Example*

```puppet
database { 'mydb':
  charset => 'latin1',
}
 
database_user { 'bob@localhost':
  password_hash => mysql_password('foo')
}
 
database_grant { 'user@localhost/database':
  privileges => ['all'] ,
}
```
