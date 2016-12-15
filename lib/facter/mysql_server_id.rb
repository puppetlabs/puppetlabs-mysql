def get_mysql_id
  Facter.value(:macaddress).split(':')[2..-1].reduce(0) { |total, value| (total << 6) + value.hex }
end

Facter.add('mysql_server_id') do
  setcode do
    begin
      get_mysql_id
    rescue
      nil
    end
  end
end
