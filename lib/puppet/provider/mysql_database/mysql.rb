Puppet::Type.type(:mysql_database).provide(:mysql) do
  desc 'Manages MySQL databases.'

  commands :mysql      => 'mysql'

  def self.defaults_file
    if File.file?("#{Facter.value(:root_home)}/.my.cnf")
      "--defaults-file=#{Facter.value(:root_home)}/.my.cnf"
    else
      nil
    end
  end

  def defaults_file
    self.class.defaults_file
  end

  def self.instances
    mysql([defaults_file, '-NBe', 'show databases'].compact).split("\n").collect do |name|
      attributes = {}
      mysql([defaults_file, '-NBe', 'show variables like "%_database"', name].compact).split("\n").each do |line|
        k,v = line.split(/\s/)
        attributes[k] = v
      end
      new(:name => name,
          :characterset => attributes['character_set_database'],
          :collate      => attributes['collation_database']
         )
    end
  end

  def create
    mysql([defaults_file, '-NBe', "create database `#{@resource[:name]}` character set #{resource[:charset]}"].compact)
  end

  def destroy
    mysql([defaults_file, '-NBe', "drop database `#{@resource[:name]}`"].compact)
  end

  def charset
    mysql([defaults_file, '-NBe', 'show variables like "%_database"', resource[:name]].compact).match(/character_set_database\s+(.*)/)[1]
  end

  def charset=(value)
    mysql([defaults_file, '-NBe', "alter database `#{resource[:name]}` CHARACTER SET #{value}"].compact)
  end

  def collate
    mysql([defaults_file, '-NBe', 'show variables like "%_database"', resource[:name]].compact).match(/collation_database\s+(.*)/)[1]
  end

  def collate=(value)
    mysql([defaults_file, '-NBe', "alter database `#{resource[:name]}` COLLATE #{value}"].compact)
  end

  def exists?
    begin
      mysql([defaults_file, '-NBe', 'show databases'].compact).match(/^#{@resource[:name]}$/)
    rescue Puppet::ExecutionFailure => e
      false
    end
  end

end
