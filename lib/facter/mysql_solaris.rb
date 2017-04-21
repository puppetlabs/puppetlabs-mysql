Facter.add('mysql_solaris') do
  begin
    # Get the mediated version of mysql and update PATH
    # Fallback to the previously hard coded version (5.5) if there is no mediator
    ver = Facter::Util::Resolution.exec('pkg mediator -H mysql').split[2]

    # Above exec doesn't raise an error if the command returns non-zero results
    ver = ver.nil? ? '5.5' : ver
  rescue
    # Just in case this raises an error in the future
    ver = '5.5'
  end
  setcode do
    {
      'basedir'          => "/usr/mysql/#{ver}",
      'major_dot_minor'  => ver,
      'major_minor'      => ver.tr('.', '')
    }
  end
end
