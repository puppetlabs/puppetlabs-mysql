# Returns the dirname of a path.
module Puppet::Parser::Functions
  newfunction(:mysql_dirname, type: :rvalue, doc: <<-EOS
    Returns the dirname of a path.
    EOS
             ) do |arguments|

    if arguments.empty?
      raise(Puppet::ParseError, 'mysql_dirname(): Wrong number of arguments ' \
        "given (#{arguments.size} for 1)")
    end

    path = arguments[0]
    return File.dirname(path)
  end
end

# vim: set ts=2 sw=2 et :
