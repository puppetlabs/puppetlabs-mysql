def get_mysql_id
    mysql_id = nil;
    
    if Facter.value(:ipaddress) != nil
      mysql_id = Facter.value(:ipaddress).split('.').inject(0) {|total,value| (total << 8 ) + value.to_i}
    else
      mysql_id = Facter.value(:ipaddress6).split(':').inject(0) {|total,value| (total << 2) + value.hex}
    end
    
end

Facter.add("mysql_server_id") do
    setcode do
        get_mysql_id
    end
end