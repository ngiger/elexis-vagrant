# got it via https://github.com/camptocamp/puppet-common
# written by David Schmitt
# Copyright (C) 2007 David Schmitt
# <david@schmitt.edv-bus.at>
module Puppet::Parser::Functions
  newfunction(:installJubula) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    puts "in installJubula"
    url           = args[0]
    setupLocation = args[1]
    installPath   = args[2]
    scriptFile    = args[3]
    p url
    dir = File.dirname(setupLocation)
    FileUtils.makedirs(dir) if !File.directory?(dir)
    cmd1  = "curl -s -o #{setupLocation} #{url}"
    cmd2 = "#{scriptFile} #{setupLocation} #{installPath}"
    if !File.exists?(setupLocation)
      if Puppet[:noop]
	puts "#{__FILE__}: noop: #{cmd1}"
      else
	puts "#{__FILE__}: #{cmd1}"
	res = system(cmd1)
	puts res
      end
    else
	puts "#{__FILE__}: skipping get : #{setupLocation}"
    end
    if !File.directory?(installPath+'/jubula')
      Dir.chdir(File.dirname(setupLocation))
      if Puppet[:noop]
	puts "#{__FILE__}: noop: #{cmd2}"
      else
	puts "#{__FILE__}: #{cmd2}"
	res = system(cmd2)
	puts res
      end
    else
	puts "#{__FILE__}: skipping inst: #{installPath}"
    end
  end
end