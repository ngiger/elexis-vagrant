#!/usr/bin/env ruby

require 'fileutils'

unless ARGV.size == 3
  puts "#{__FILE__} must be invoked with three params: username service_name exec_and_arguments"
  exit 1
end

username        = ARGV[0]
service_name    = ARGV[1]
service_origin  = ARGV[2]

def createRunFile(name, user, service_origin)
  runName = "/var/lib/service/#{name}/run"
  return if File.exists?(runName)
  FileUtils.makedirs(File.dirname(runName)) unless File.directory?(File.dirname(runName))
  ausgabe = File.open(runName, 'w+')
  ausgabe.puts "#!/bin/sh
exec 2>&1
ulimit -v 10240000
exec sudo -u #{user} #{service_origin}
"
  FileUtils.chmod(0754, runName)
end

createRunFile(service_name, username, service_origin)

