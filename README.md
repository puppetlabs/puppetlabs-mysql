# Mysql module for Puppet


## Description
This module has evolved and is originally based on work by David Schmitt.
If anyone else was involved in the development of this module
and wants credit, let Puppetlabs know.

## Usage

### mysql
Installs the mysql-client package.
<pre>
class { 'mysql': }
</pre>

### mysql::python
Installs mysql bindings for python.
<pre>
class { 'mysql::python': }
</pre>

### mysql::ruby
Installs mysql bindings for ruby.
<pre>
class { 'mysql::ruby': }
</pre>

### mysql::server
Installs mysql-server, starts service, sets `root_pw`, and sets root.
<pre>
class { 'mysql::server':
  config_hash => { 'root_password' => 'foo' }
}
</pre>

Login information in `/etc/.my.cnf` and `/root/.my.cnf`.

### mysql::db
Creates a database with a user and assign some privileges.

<pre>
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['all'],
}
</pre>

### Providers for database types:
<pre>
database { 'mydb':
  charset => 'latin1',
}
</pre>

<pre>
database_user { 'bob@localhost':
  password_hash => mysql_password('foo')
}
</pre>

<pre>
# for global grants
database_grant { 'user@localhost':
  privileges => ['all'] ,
}	
# for db specific grants
database_grant { 'user@localhost/database':
  privileges => ['all'] ,
}
</pre>
