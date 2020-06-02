def mysql_id_get
  # Convert the existing mac to an integer
  macval = Facter.value(:macaddress).delete(':').to_i(16)

  # Valid range is from 1 - 4294967295 for replication hosts.
  # We can not guarantee a fully unique value, this reduces the
  # full mac value down to into that number space.
  #
  # The -1/+1 ensures that we keep above 1 if we get unlucky
  # enough to hit a mac address that evenly divides.
  (macval % (4_294_967_295 - 1)) + 1
end

Facter.add('mysql_server_id') do
  setcode do
    begin
      mysql_id_get
    rescue
      nil
    end
  end
end
