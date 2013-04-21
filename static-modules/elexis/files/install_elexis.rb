#!/usr/bin/env ruby
puts Dir.pwd
puts ARGV.inspect
installer = ARGV[0]
installDir = ARGV[1]
installDemoDemoDB =  ARGV[2] ? true : false
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
Dir.chdir(installDir)
# patch <installpath>/opt/elexis_opensource/2.1.7.rc2</installpath>
# patch <pack index="0" name="DemoDB" selected="false"/>
cmd = "java -jar #{installer} #{tmpName}"
puts cmd
res = system(cmd)
puts "res #{res} for cmd #{cmd}"
if res then exit(0) else exit(1) end;

