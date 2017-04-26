def get_mysql_id
    mysql_id = nil;
    mysql_id = Facter.value(:ipaddress).split('.').inject(0) {|total,value| (total << 8 ) + value.to_i}
end

Facter.add("mysql_server_id") do
    setcode do
        get_mysql_id
    end
end
