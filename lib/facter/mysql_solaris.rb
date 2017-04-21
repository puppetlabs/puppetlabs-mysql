Facter.add('mysql_solaris') do
  setcode {}
end
Facter.add('mysql_solaris') do
  constrain osfamily: 'Solaris'
  begin
    # Get the mediated version of mysql and update PATH
    # Fallback to the previously hard coded version (5.5) if there is no mediator
    ver = Facter::Util::Resolution.exec('pkg mediator -H mysql').split[2]
  rescue
    ver ||= '5.5'
  end
  setcode do
    {
      'basedir'          => "/usr/mysql/#{ver}",
      'major_dot_minor'  => ver,
      'major_minor'      => ver.tr('.', '')
    }
  end
end
