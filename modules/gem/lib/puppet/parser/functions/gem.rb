

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
  newfunction(:gem) do |args|
    gemCmd = "/usr/bin/gem"
    gemName   = args[0]
    operation = args[1]
    version   = args[2]
    options   = args[3]
    cmd = gemCmd
    installed = false
    gemName += " --version=#{version}" if version && version != "nil"
    if gemIsPresent(gemName, version)
      return if operation == "install"
      cmd += " uninstall #{gemName}"
    else
      return if operation == "absent" || operation == "uninstall"
      cmd += " install #{gemName} #{options}"
    end    
    system(cmd)
  end
end