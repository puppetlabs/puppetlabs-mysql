#!/opt/puppetlabs/puppet/bin/ruby
require 'json'
require 'open3'
require 'puppet'

def parse_output(stdout)
  return [] if stdout == ''
  rows = stdout.split("\n")
  columns = rows.shift

  columns = columns.split("\t")
  rows.map do |row|
    Hash[columns.zip row.split("\t")]
  end
end

def parse_error(stderr)
  if (matches = stderr.match(%r{^ERROR\s(?<error_code>\d+)\s\((?<sql_state>\w{5})\)( at line (?<line_number>\d+))?:\s(?<description>.+)$}))
    details = {
      mysql_error_code: matches[:error_code],
      mysql_sqlstate: matches[:sql_state],
      mysql_error_description: matches[:description],
    }
    details[:mysql_error_line_number] = matches[:line_number] unless matches[:line_number].nil?
  else
    details = { stderr: stderr }
  end
  {
    msg: 'Call to mysql failed',
    kind: 'puppetlabs-mysql/mysql_error',
    details: details,
  }
end

params = JSON.parse(STDIN.read)

database   = params['database']
user       = params['user']
password   = params['password']
sql        = params['sql']
structured = params['structured']

cmd = ['mysql', '-e', "#{sql} "]
cmd << "--database=#{database}" unless database.nil?
cmd << "--user=#{user}" unless user.nil?
cmd << "--password=#{password}" unless password.nil?

begin
  result = {}
  stdout, stderr, status = Open3.capture3(*cmd)

  if status.success?
    if structured
      result[:mysql_results] = parse_output(stdout)
    else
      result[:status] = stdout.strip
    end
  else
    result[:_error] = parse_error(stderr)
  end
rescue Errno::ENOENT => e
  result[:_error] = {
    msg: 'Cannot execute mysql',
    kind: 'puppetlabs-mysql/enoent',
    details: e.message,
  }
end

puts result.to_json
