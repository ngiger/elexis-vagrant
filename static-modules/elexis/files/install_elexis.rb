#!/usr/bin/env ruby
require 'fileutils'
require 'open-uri'
DemoDB = 'http://ftp.medelexis.ch/downloads_opensource/elexis/demoDB/demoDB_elexis_2.1.5.4.zip'
if ARGV.size < 2
  puts "#{__FILE__} expects at leas two parameteres URL_of_installer /path/to/install [withDemoDb=false]"
  exit 2
end
installer = ARGV[0]
installDir = ARGV[1]
installDemoDemoDB =  ARGV[2] ? true : false
unless File.exists?(installer)
  tmpName = "/tmp/#{File.basename(installer)}"
  puts "Downloading #{installer} -> #{tmpName}"
  writeOut = open(tmpName, "wb") 
  writeOut.write(open(installer).read) 
  writeOut.close
  installer = tmpName 
end

eingabe = IO.readlines('/etc/auto_install_elexis.xml')
tmpName = '/tmp/auto_install_elexis.xml'
ausgabe = File.open(tmpName, 'w+')
eingabe.each{ 
  |line|
  if /installpath/.match(line)
    ausgabe.puts "<installpath>#{installDir}/</installpath>"
  elsif installDemoDemoDB and /name="DemoDB/.match(line)
    ausgabe.puts '<pack index="0" name="DemoDB" selected="true"/>'
  else
    ausgabe.puts line
  end
}
ausgabe.close

puts "installDemoDemoDB ist #{installDemoDemoDB}"
FileUtils.makedirs(installDir) unless File.directory?(installDir)
Dir.chdir(installDir)
cmd = "java -jar #{installer} #{tmpName}"
puts cmd
res = system(cmd)
puts "res #{res} for cmd #{cmd}"
if res then exit(0) else exit(1) end;

