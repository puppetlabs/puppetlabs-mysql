# mysql

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with mysql](#setup)
    * [Beginning with mysql](#beginning-with-mysql)
3. [Usage - Configuration options and additional functionality](#usage)
    * [Customize server options](#customize-server-options)
    * [Create a database](#create-a-database)
    * [Customize configuration](#customize-configuration)
    * [Work with an existing server](#work-with-an-existing-server)
    * [Specify passwords](#specify-passwords)
    * [Install Percona server on CentOS](#install-percona-server-on-centos)
    * [Install MariaDB on Ubuntu](#install-mariadb-on-ubuntu)
    * [Install Plugins](#install-plugins)
    * [Use Percona XtraBackup](#use-percona-xtrabackup)
4. [Reference - An under-the-hood peek at what the module is doing and how](REFERENCE.md)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Module Description

The mysql module installs, configures, and manages the MySQL service.

This module manages both the installation and configuration of MySQL, as well as extending Puppet to allow management of MySQL resources, such as databases, users, and grants.

## Setup

### Beginning with mysql

To install a server with the default options:

`include mysql::server`.

To customize options, such as the root password or `/etc/my.cnf` settings, you must also pass in an override hash:

```puppet
class { 'mysql::server':
  root_password           => 'strongpassword',
  remove_default_accounts => true,
  restart                 => true,
  override_options        => $override_options,
}
```

Nota bene: Configuration changes will only be applied to the running
MySQL server if you pass true as restart to mysql::server.

See [**Customize Server Options**](#customize-server-options) below for examples of the hash structure for $override_options.

## Usage

All interaction for the server is done via `mysql::server`. To install the client, use `mysql::client`. To install bindings, use `mysql::bindings`.

### Customize server options

To define server options, structure a hash structure of overrides in `mysql::server`. This hash resembles a hash in the my.cnf file:

```puppet
$override_options = {
  'section' => {
    'item' => 'thing',
  },
}
```

For options that you would traditionally represent in this format:

```ini
[section]
thing = X
```

Entries can be created as `thing => true`, `thing => value`, or `thing => ""` in the hash. Alternatively, you can pass an array as `thing => ['value', 'value2']` or list each `thing => value` separately on individual lines.

You can pass a variable in the hash without setting a value for it; the variable would then use MySQL's default settings. To exclude an option from the `my.cnf` file --- for example, when using `override_options` to revert to a default value --- pass `thing => undef`.

If an option needs multiple instances, pass an array. For example,

```puppet
$override_options = {
  'mysqld' => {
    'replicate-do-db' => ['base1', 'base2'],
  },
}
```

produces

```ini
[mysqld]
replicate-do-db = base1
replicate-do-db = base2
```

To implement version specific parameters, specify the version, such as [mysqld-5.5]. This allows one config for different versions of MySQL.

If you don’t want to use the default configuration, you can also supply your options to the `$options` parameter instead of `$override_options`.
Please note that `$options` and `$override_options` are mutually exclusive, you can only use one of them.

By default, the puppet won't reload/restart mysqld when you change an existing
configuration. If you want to do that, you can set
`mysql::server::reload_on_config_change` to true.

### Create a database

To create a database with a user and some assigned privileges:

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => 'mypass',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
```

To use a different resource name with exported resources:

```puppet
 @@mysql::db { "mydb_${fqdn}":
  user     => 'myuser',
  password => 'mypass',
  dbname   => 'mydb',
  host     => ${fqdn},
  grant    => ['SELECT', 'UPDATE'],
  tag      => $domain,
}
```

Then you can collect it on the remote DB server:

```puppet
Mysql::Db <<| tag == $domain |>>
```

If you set the sql parameter to a file when creating a database, the file is imported into the new database.

For large sql files, increase the `import_timeout` parameter, which defaults to 300 seconds.

If you have installed the mysql client in a non standard bin/sbin path you can set this with `mysql_exec_path` .

```puppet
mysql::db { 'mydb':
  user            => 'myuser',
  password        => 'mypass',
  host            => 'localhost',
  grant           => ['SELECT', 'UPDATE'],
  sql             => ['/path/to/sqlfile.gz'],
  import_cat_cmd  => 'zcat',
  import_timeout  => 900,
  mysql_exec_path => '/opt/rh/rh-myql57/root/bin',
}
```

### Customize configuration

To add custom MySQL configuration, place additional files into `includedir`. This allows you to override settings or add additional ones, which is helpful if you don't use `override_options` in `mysql::server`. The `includedir` location is by default set to `/etc/mysql/conf.d`.

### Managing Root Passwords

If you want the password managed by puppet for `127.0.0.1` and `::1` as an end user you would need to explicitly manage them with additional manifest entries. For example:

```puppet
mysql_user { '[root@127.0.0.1]':
  ensure        => present,
  password_hash => mysql::password($mysql::server::root_password),
}

mysql_user { 'root@::1':
  ensure        => present,
  password_hash => mysql::password($mysql::server::root_password),
}
```

**Note:** This module is not designed to carry out additional DNS and aliasing.

### Work with an existing server

To instantiate databases and users on an existing MySQL server, you need a `.my.cnf` file in `root`'s home directory. This file must specify the remote server address and credentials. For example:

```ini
[client]
user=root
host=localhost
password=secret
```

This module uses the `mysqld_version` fact to discover the server version being used.  By default, this is set to the output of `mysqld -V`.  If you're working with a remote MySQL server, you may need to set a custom fact for `mysqld_version` to ensure correct behaviour.

When working with a remote server, do *not* use the `mysql::server` class in your Puppet manifests.

### Specify passwords

In addition to passing passwords as plain text, you can input them as hashes. For example:

```puppet
mysql::db { 'mydb':
  user     => 'myuser',
  password => '*6C8989366EAF75BB670AD8EA7A7FC1176A95CEF4',
  host     => 'localhost',
  grant    => ['SELECT', 'UPDATE'],
}
```

If required, the password can also be an empty string to allow connections without an password.

### Create login paths

This feature works only for the MySQL Community Edition >= 5.6.6.

A login path is a set of options (host, user, password, port and socket) that specify which MySQL server to connect to and which account to authenticate as. The authentication credentials and the other options are stored in an encrypted login file named .mylogin.cnf typically under the users home directory.

More information about MySQL login paths: https://dev.mysql.com/doc/refman/8.0/en/mysql-config-editor.html.

Some example for login paths:

```puppet
mysql_login_path { 'client':
  owner    => root,
  host     => 'localhost',
  user     => 'root',
  password => Sensitive('secure'),
  socket   => '/var/run/mysqld/mysqld.sock',
  ensure   => present,
}

mysql_login_path { 'remote_db':
  owner    => root,
  host     => '10.0.0.1',
  user     => 'network',
  password => Sensitive('secure'),
  port     => 3306,
  ensure   => present,
}
```
See examples/mysql_login_path.pp for further examples.

### Install Percona server on CentOS

This example shows how to do a minimal installation of a Percona server on a
CentOS system. This sets up the Percona server, client, and bindings (including Perl and Python bindings). You can customize this usage and update the version as needed.

This usage has been tested on Puppet 4.4, 5.5 and 6.3.0 / CentOS 7 / Percona Server 5.7.

**Note:** The installation of the yum repository is not part of this package
and is here only to show a full example of how you can install.

```puppet
yumrepo { 'percona':
  descr    => 'CentOS $releasever - Percona',
  baseurl  => 'http://repo.percona.com/percona/yum/release/$releasever/RPMS/$basearch',
  gpgkey   => 'https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
  enabled  => 1,
  gpgcheck => 1,
}

class { 'mysql::server':
  package_name     => 'Percona-Server-server-57',
  service_name     => 'mysql',
  config_file      => '/etc/my.cnf',
  includedir       => '/etc/my.cnf.d',
  root_password    => 'PutYourOwnPwdHere',
  override_options => {
    mysqld => {
      log-error => '/var/log/mysqld.log',
      pid-file  => '/var/run/mysqld/mysqld.pid',
    },
    mysqld_safe => {
      log-error => '/var/log/mysqld.log',
    },
  },
}

# Note: Installing Percona-Server-server-57 also installs Percona-Server-client-57.
# This shows how to install the Percona MySQL client on its own
class { 'mysql::client':
  package_name => 'Percona-Server-client-57',
}

# These packages are normally installed along with Percona-Server-server-57
# If you needed to install the bindings, however, you could do so with this code
class { 'mysql::bindings':
  client_dev_package_name => 'Percona-Server-shared-57',
  client_dev              => true,
  daemon_dev_package_name => 'Percona-Server-devel-57',
  daemon_dev              => true,
  perl_enable             => true,
  perl_package_name       => 'perl-DBD-MySQL',
  python_enable           => true,
  python_package_name     => 'MySQL-python',
}

# Dependencies definition
Yumrepo['percona']->
Class['mysql::server']

Yumrepo['percona']->
Class['mysql::client']

Yumrepo['percona']->
Class['mysql::bindings']
```

### Install MariaDB on Ubuntu

#### Optional: Install the MariaDB official repo

In this example, we'll use the latest stable (currently 10.3) from the official MariaDB repository, not the one from the distro repository. You could instead use the package from the Ubuntu repository. Make sure you use the repository corresponding to the version you want.

**Note:** `sfo1.mirrors.digitalocean.com` is one of many mirrors available. You can use any official mirror.

```puppet
include apt

apt::source { 'mariadb':
  location => 'http://sfo1.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu',
  release  => $::facts['os']['codename'],
  repos    => 'main',
  key      => {
    id     => '177F4010FE56CA3336300305F1656F24C74CD1D8',
    server => 'hkp://keyserver.ubuntu.com:80',
  },
  include => {
    src   => false,
    deb   => true,
  },
}
```

#### Install the MariaDB server

This example shows MariaDB server installation on Ubuntu Xenial. Adjust the version and the parameters of `my.cnf` as needed. All parameters of the `my.cnf` can be defined using the `override_options` parameter.

The folders `/var/log/mysql` and `/var/run/mysqld` are created automatically, but if you are using other custom folders, they should exist as prerequisites for this code.

All the values set here are an example of a working minimal configuration.

Specify the version of the package you want with the `package_ensure` parameter.

```puppet
class { 'mysql::server':
  package_name     => 'mariadb-server',
  package_ensure   => '1:10.3.21+maria~xenial',
  service_name     => 'mysqld',
  root_password    => 'AVeryStrongPasswordUShouldEncrypt!',
  override_options => {
    mysqld => {
      'log-error' => '/var/log/mysql/mariadb.log',
      'pid-file'  => '/var/run/mysqld/mysqld.pid',
    },
    mysqld_safe => {
      'log-error' => '/var/log/mysql/mariadb.log',
    },
  },
}

# Dependency management. Only use that part if you are installing the repository
# as shown in the Preliminary step of this example.
Apt::Source['mariadb'] ~>
Class['apt::update'] ->
Class['mysql::server']

```

#### Install the MariaDB client

This example shows how to install the MariaDB client and all of the bindings at once. You can do this installation separately from the server installation.

Specify the version of the package you want with the `package_ensure` parameter.

```puppet
class { 'mysql::client':
  package_name    => 'mariadb-client',
  package_ensure  => '1:10.3.21+maria~xenial',
  bindings_enable => true,
}

# Dependency management. Only use that part if you are installing the repository as shown in the Preliminary step of this example.
Apt::Source['mariadb'] ~>
Class['apt::update'] ->
Class['mysql::client']
```

### Install MySQL Community server on CentOS

You can install MySQL Community Server on CentOS using the mysql module and Hiera. This example was tested with the following versions:

* MySQL Community Server 5.6
* Centos 7.3
* Puppet 3.8.7 using Hiera
* puppetlabs-mysql module v3.9.0

In Puppet:

```puppet
include mysql::server

create_resources(yumrepo, hiera('yumrepo', {}))

Yumrepo['repo.mysql.com'] -> Anchor['mysql::server::start']
Yumrepo['repo.mysql.com'] -> Package['mysql_client']

create_resources(mysql::db, hiera('mysql::server::db', {}))
```

In Hiera:

```yaml
---

# Centos 7.3
yumrepo:
  'repo.mysql.com':
    baseurl: "http://repo.mysql.com/yum/mysql-5.6-community/el/%{::operatingsystemmajrelease}/$basearch/"
    descr: 'repo.mysql.com'
    enabled: 1
    gpgcheck: true
    gpgkey: 'http://repo.mysql.com/RPM-GPG-KEY-mysql'

mysql::client::package_name: "mysql-community-client" # required for proper MySQL installation
mysql::server::package_name: "mysql-community-server" # required for proper MySQL installation
mysql::server::package_ensure: 'installed' # do not specify version here, unfortunately yum fails with error that package is already installed
mysql::server::root_password: "change_me_i_am_insecure"
mysql::server::manage_config_file: true
mysql::server::service_name: 'mysqld' # required for puppet module
mysql::server::override_options:
  'mysqld':
    'bind-address': '127.0.0.1'
    'log-error': '/var/log/mysqld.log' # required for proper MySQL installation
  'mysqld_safe':
    'log-error': '/var/log/mysqld.log'  # required for proper MySQL installation

# create database + account with access, passwords are not encrypted
mysql::server::db:
  "dev":
    user: "dev"
    password: "devpass"
    host: "127.0.0.1"
    grant:
      - "ALL"

```

### Install Plugins

Plugins can be installed by using the `mysql_plugin` defined type. See `examples/mysql_plugin.pp` for futher examples.

### Use Percona XtraBackup

This example shows how to configure MySQL backups with Percona XtraBackup. This sets up a weekly cronjob to perform a full backup and additional daily cronjobs for incremental backups. Each backup will create a new directory. A cleanup job will automatically remove backups that are older than 15 days.

```puppet
yumrepo { 'percona':
  descr    => 'CentOS $releasever - Percona',
  baseurl  => 'http://repo.percona.com/release/$releasever/RPMS/$basearch',
  gpgkey   => 'https://www.percona.com/downloads/RPM-GPG-KEY-percona https://repo.percona.com/yum/PERCONA-PACKAGING-KEY',
  enabled  => 1,
  gpgcheck => 1,
}

class { 'mysql::server::backup':
  backupuser        => 'myuser',
  backuppassword    => 'mypassword',
  backupdir         => '/tmp/backups',
  provider          => 'xtrabackup',
  backuprotate      => 15,
  execpath          => '/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
  time              => ['23', '15'],
}
```

If the daily or weekly backup was successful, then the empty file `/tmp/mysqlbackup_success` is created, which makes it easy to monitor the status of the database backup.

After two weeks the backup directory should look similar to the example below.

```
/tmp/backups/2019-11-10_full
/tmp/backups/2019-11-11_23-15-01
/tmp/backups/2019-11-13_23-15-01
/tmp/backups/2019-11-13_23-15-02
/tmp/backups/2019-11-14_23-15-01
/tmp/backups/2019-11-15_23-15-02
/tmp/backups/2019-11-16_23-15-01
/tmp/backups/2019-11-17_full
/tmp/backups/2019-11-18_23-15-01
/tmp/backups/2019-11-19_23-15-01
/tmp/backups/2019-11-20_23-15-02
/tmp/backups/2019-11-21_23-15-01
/tmp/backups/2019-11-22_23-15-02
/tmp/backups/2019-11-23_23-15-01
```

A drawback of using incremental backups is the need to keep at least 7 days of backups, otherwise the full backups is removed early and consecutive incremental backups will fail. Furthermore an incremental backups becomes obsolete once the required full backup was removed.

The next example uses XtraBackup with incremental backups disabled. In this case the daily cronjob will always perform a full backup.

```puppet
class { 'mysql::server::backup':
  backupuser          => 'myuser',
  backuppassword      => 'mypassword',
  backupdir           => '/tmp/backups',
  provider            => 'xtrabackup',
  incremental_backups => false,
  backuprotate        => 5,
  execpath            => '/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
  time                => ['23', '15'],
}
```

The next example shows how to use mariabackup (a fork of xtrabackup) as a backup provider.
Note that on most Linux/BSD distributions, this will require setting `backupmethod_package => 'mariadb-backup'` in the `mysql::server::backup` declaration in order to override the default xtrabackup package (`percona-xtrabackup`).

```puppet
class { 'mysql::server':
  package_name            => 'mariadb-server',
  package_ensure          => '1:10.3.21+maria~xenial',
  service_name            => 'mysqld',
  root_password           => 'AVeryStrongPasswordUShouldEncrypt!',
}

class { 'mysql::server::backup':
  backupuser              => 'mariabackup',
  backuppassword          => 'AVeryStrongPasswordUShouldEncrypt!',
  provider                => 'xtrabackup',
  backupmethod            => 'mariabackup',
  backupmethod_package    => 'mariadb-backup',
  backupdir               => '/tmp/backups',
  backuprotate            => 15,
  execpath                => '/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
  time                    => ['23', '15'],
}
```

## Reference

### Classes

#### Public classes

* [`mysql::server`](#mysqlserver): Installs and configures MySQL.
* [`mysql::server::backup`](#mysqlserverbackup): Sets up MySQL backups via cron.
* [`mysql::bindings`](#mysqlbindings): Installs various MySQL language bindings.
* [`mysql::client`](#mysqlclient): Installs MySQL client (for non-servers).

#### Private classes

* `mysql::server::install`: Installs packages.
* `mysql::server::installdb`: Implements setup of mysqld data directory (e.g. /var/lib/mysql)
* `mysql::server::config`: Configures MYSQL.
* `mysql::server::service`: Manages service.
* `mysql::server::account_security`: Deletes default MySQL accounts.
* `mysql::server::root_password`: Sets MySQL root password.
* `mysql::server::providers`: Creates users, grants, and databases.
* `mysql::bindings::client_dev`: Installs MySQL client development package.
* `mysql::bindings::daemon_dev`: Installs MySQL daemon development package.
* `mysql::bindings::java`: Installs Java bindings.
* `mysql::bindings::perl`: Installs Perl bindings.
* `mysql::bindings::php`: Installs PHP bindings.
* `mysql::bindings::python`: Installs Python bindings.
* `mysql::bindings::ruby`: Installs Ruby bindings.
* `mysql::client::install`:  Installs MySQL client.
* `mysql::backup::mysqldump`: Implements mysqldump backups.
* `mysql::backup::mysqlbackup`: Implements backups with Oracle MySQL Enterprise Backup.
* `mysql::backup::xtrabackup`: Implements backups with XtraBackup from Percona or Mariabackup.

### Parameters

#### mysql::server

##### `create_root_user`

Whether root user should be created.

Valid values are `true`, `false`.

Defaults to `true`.

This is useful for a cluster setup with Galera. The root user has to be created only once. You can set this parameter true on one node and set it to false on the remaining nodes.

#####  `create_root_my_cnf`

Whether to create `/root/.my.cnf`.

Valid values are `true`, `false`.

Defaults to `true`.

`create_root_my_cnf` allows creation of `/root/.my.cnf` independently of `create_root_user`. You can use this for a cluster setup with Galera where you want `/root/.my.cnf` to exist on all nodes.

#####  `root_password`

The MySQL root password. Puppet attempts to set the root password and update `/root/.my.cnf` with it.

This is required if `create_root_user` or `create_root_my_cnf` are true. If `root_password` is 'UNSET', then `create_root_user` and `create_root_my_cnf` are assumed to be false --- that is, the MySQL root user and `/root/.my.cnf` are not created.

Password changes are supported; however, the old password must be set in `/root/.my.cnf`. Effectively, Puppet uses the old password, configured in `/root/my.cnf`, to set the new password in MySQL, and then updates `/root/.my.cnf` with the new password.

##### `old_root_password`

This parameter no longer does anything. It exists only for backwards compatibility. See the `root_password` parameter above for details on changing the root password.

#####  `create_root_login_file`

Whether to create `/root/.mylogin.cnf` when using mysql 5.6.6+.

Valid values are `true`, `false`.

Defaults to `false`.

`create_root_login_file` will put a copy of your existing `.mylogin.cnf` in the  `/root/.mylogin.cnf` location.

When set to 'true', this option also requires the `login_file` option.

The `login_file` option is required when set to true.

#### `login_file`

Whether to put the `/root/.mylogin.cnf` in place.

You need to create the `.mylogin.cnf` file with `mysql_config_editor`, this tool comes with mysql 5.6.6+.

The created .mylogin.cnf needs to be put under files in your module, see example below on how to use this.

When the `/root/.mylogin.cnf` exists the environment variable `MYSQL_TEST_LOGIN_FILE` will be set.

This is required if `create_root_user` and `create_root_login_file` are true. If `root_password` is 'UNSET', then `create_root_user` and `create_root_login_file` are assumed to be false --- that is, the MySQL root user and `/root/.mylogin.cnf` are not created.

```puppet
class { 'mysql::server':
  root_password          => 'password',
  create_root_my_cnf     => false,
  create_root_login_file => true,
  login_file             => 'puppet:///modules/${module_name}/mylogin.cnf',
}
```

##### `override_options`

Specifies override options to pass into MySQL. Structured like a hash in the my.cnf file:

```puppet
class { 'mysql::server':
  root_password => 'password'
}

mysql_plugin { 'auth_pam':
  ensure => present,
  soname => 'auth_pam.so',
}

```

### Tasks

The MySQL module has an example task that allows a user to execute arbitary SQL against a database. Please refer to to the [PE documentation](https://puppet.com/docs/pe/2017.3/orchestrator/running_tasks.html) or [Bolt documentation](https://puppet.com/docs/bolt/latest/bolt.html) on how to execute a task.

## Limitations

For an extensive list of supported operating systems, see [metadata.json](https://github.com/puppetlabs/puppetlabs-mysql/blob/main/metadata.json)

**Note:** The mysqlbackup.sh does not work and is not supported on MySQL 5.7 and greater.

## Development

We are experimenting with a new tool for running acceptance tests. Its name is [puppet_litmus](https://github.com/puppetlabs/puppet_litmus) this replaces beaker as the test runner. To run the acceptance tests follow the [instructions](https://puppetlabs.github.io/litmus/Running-acceptance-tests.html) from the Litmus documentation.

Puppet modules on the Puppet Forge are open projects, and community contributions are essential for keeping them great. We can't access the huge number of platforms and myriad of hardware, software, and deployment configurations that Puppet is intended to serve.

We want to keep it as easy as possible to contribute changes so that our modules work in your environment. There are a few guidelines that we need contributors to follow so that we can have a chance of keeping on top of things.

Check out our the complete [module contribution guide](https://puppet.com/docs/puppet/latest/contributing.html).

### Authors

This module is based on work by David Schmitt. Thank you to all of our [contributors](https://github.com/puppetlabs/puppetlabs-mysql/graphs/contributors).
