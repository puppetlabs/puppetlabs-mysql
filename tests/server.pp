#
# I need a way to specify the old password, 
# is the old password is specified and not set in the 
# .my.cnf file, then we are hosed
#$mysql_old_pw='password2'
$mysql_root_pw='password'
include mysql::server
