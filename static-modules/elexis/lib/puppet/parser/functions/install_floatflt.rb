# (adapted from http://lists.debian.org/debian-user-german/2004/10/msg01147.html)
require 'tmpdir'
module Puppet::Parser::Functions
  newfunction(:install_floatflt) do |args|
    destDir = args[0]
    floatZipName = args[1]
    Puppet::Parser::Functions.autoloader.loadall
    savedDir = Dir.pwd
    workDir = "/tmp/inst_float_"+Time.now.strftime("%H%M%S")
    destFile = "#{destDir}/floatflt.sty"
    if File.exists?(destFile)
      puts "Skipping as #{destFile} already exists"
    else
      FileUtils.makedirs(workDir) if !File.directory?(workDir)
      FileUtils.makedirs(destDir) if !File.directory?(destDir)
      Dir.chdir(workDir)
      cmds = ["pwd",
	      "unzip -d . #{floatZipName}",
	      "cd #{workDir}/floatflt && latex floatflt.ins",
	      "cp #{workDir}/floatflt/floatflt.sty #{destFile}",
	    "texhash",
	      ]
      cmds.each { |cmd|
		  if Puppet[:noop]
		  puts "#{__FILE__}: noop: #{cmd}"
		else
		  puts "#{__FILE__}: #{cmd}"
		  res = system(cmd)
		  puts res
		  if !res then puts "cmd #{cmd} failed!" ; exit(1); end
		end
	      }
    end
    Dir.chdir(savedDir)
  end
end
