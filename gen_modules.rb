#!/usr/bin/env ruby
require 'fileutils'
if ARGV.size != 1
  puts "#{__FILE__} needs exactly one argument: name of module to create"
end
ModuleName = ARGV[0]
puts "Generating directory structure for puppet module #{ModuleName}"
['lib','files','manifests','templates','tests'].each {
	|subdir|
		mySubDir = "modules/#{ModuleName}/#{subdir}"
		if File.directory?(mySubDir)
		  puts "directory #{mySubDir} exists already. Nothing to be done"
		  exit(0)
		end
		FileUtils.makedirs(mySubDir)
}

init = <<EOF
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
class #{ModuleName} {
# class #{ModuleName}($parameter1 = default1, $parameter2 = default2) {
# case $parameter1 {
#     'value1': { }
#     default: { }
# }
# File['/etc/ntp.conf'] -> Service['ntpd']
}
EOF
test = <<EOF
# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
include #{ModuleName}
EOF

File.open("modules/#{ModuleName}/manifests/init.pp", 'w+') { |f| f.puts(init) }
File.open("modules/#{ModuleName}/tests/init.pp"    , 'w+' ) { |f| f.puts(test) }

# mkdir-p modules/xx/{lib,files,manifests,templates,tests}