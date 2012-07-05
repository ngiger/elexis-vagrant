# (adapted from http://lists.debian.org/debian-user-german/2004/10/msg01147.html)
require 'tmpdir'
module Puppet::Parser::Functions
  newfunction(:install_floatflt) do |args|
    Puppet::Parser::Functions.autoloader.loadall
    savedDir = Dir.pwd
    floatZipName = args[0]
    Dir.mktmpdir("foo") {
      |dir| p dir
	  destDir  = '/usr/share/texmf/tex/latex/misc/'
	  destFile = "#{destDir}/floatflt.sty"
	  if File.exists?(destFile)
	    puts "Skipping as #{destFile} already exists"
    else
	  FileUtils.makedirs(dir) if !File.directory?(dir)
	  Dir.chdir(dir)
	  FileUtils.makedirs(destDir) if !File.directory?(destDir)
	  cmds = ["unzip #{floatZipName}",
		  "cd floatflt",
		  "latex floatflt.ins",
		  "cp floatflt.sty #{destFile}",
		"texhash",
		  ]
	  cmds.each { |cmd|
		      if Puppet[:noop]
			puts "#{__FILE__}: noop: #{cmd}"
		      else
			puts "#{__FILE__}: #{cmd}"
			res = system(cmd)
			puts res
		      end
		    }
    end
    }
    Dir.chdir(savedDir)
  end
end
