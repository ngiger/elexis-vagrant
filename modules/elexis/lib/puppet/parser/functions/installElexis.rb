
module Puppet::Parser::Functions
  newfunction(:installElexis) do |args|
    gemCmd = "/usr/bin/gem"
    Puppet::Parser::Functions.autoloader.loadall 
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
    if Puppet[:noop]
	puts "#{__FILE__}: noop #{cmd}"
    else
      system(cmd)
    end
  end
end