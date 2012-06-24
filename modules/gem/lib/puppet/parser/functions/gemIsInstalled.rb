def gemIsPresent(gemName, version = nil)
  gemCmd = "/usr/bin/gem"
  cmd = gemCmd
  installed = false
  gemName += " --version=#{version}" if version && version != "nil"
  listCmd  = gemCmd + " list #{gemName} --install"
  installed = `#{listCmd}`.chomp
  return installed == 'true'
end

module Puppet::Parser::Functions
  newfunction(:gemIsInstalled, :type => :rvalue) do |args|
    return gemIsPresent(args[0], args[1])
  end
end
