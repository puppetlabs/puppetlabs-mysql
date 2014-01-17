# Fact: mysql_version
#
# Purpose: Return the version of an installed mysql server
#
# Example:
# 
#   $ rpm -qa | grep mysql-5
#   mysql-5.1.71-1.el6.x86_64
#   $ mysql --version
#   mysql  Ver 14.14 Distrib 5.1.71, for redhat-linux-gnu (x86_64) using readline 5.1
#   # facter -p mysql_version
#   5.1.71
#
#
Facter.add("mysql_version") do
  setcode do
    Facter::Util::Resolution.exec('mysql --version').chomp.split(' ')[4].split(',').first
  end
end
