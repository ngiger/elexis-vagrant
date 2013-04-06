#!/usr/bin/env ruby
# coding: utf-8
# License: Eclipse Public License 1.0
# Copyright Niklaus Giger, 2011, niklaus.giger@member.fsf.org

# Allows us to run the Elexis Jubula GUI-Tests as Jenkis CI-job

require "#{File.dirname(__FILE__)}/jubularun"

opts = JubulaOptions::parseArgs
opts.parse!(ARGV)
JubulaOptions::dryRun == true ? DryRun = true : DryRun = false

jubula = JubulaRun.new(:portNumber => 60000 + (Process.pid % 1000),
                       :vmargs => "-Dch.elexis.username=007 -Dch.elexis.password=topsecret -Delexis-run-mode=RunFromScratch",
                       :dburl =>  'jdbc:mysql://jenkins:3306/jubula_vagrant')

  # For unknown reasons (which took me a few hours to code around) I decided
  # that is is not my aim to use a MySQL database to store the Jubula testcases
  # Instead we also start from a fresh, empty workspace and an empty embedded H2 db
  # Costs me a good minute

  wsDir = "#{jubula.workspace}/test-ws"
  FileUtils.rm_rf(wsDir, :verbose => true, :noop => DryRun)

jubula.useH2(wsDir)
jubula.rmTestcases
jubula.loadTestcases
jubula.autoInstall
jubula.genWrapper
jubula.prepareRcpSupport
#jubula.rmTestcases

okay1 = true	
okay1 = jubula.runOneTestcase('sample') if false
puts "okay1 ist #{okay1}"
okay2 = true
okay2 = jubula.runOneTestcase('FULLTEST')	
puts "okay2 ist #{okay2}"

Dir.glob("**/*shot*/*.png").each{ 
  |x|
      next if /images/.match(x)
      next if /plugins/.match(x)
      next if /#{File.basename(jubula.testResults)}/.match(x)
      FileUtils.cp(x, "#{jubula.testResults}", :verbose => true, :noop => DryRun)
}
if okay1 and okay2 
  puts "Sample and FULLTEST were okay!"
  exit(0);
else
  puts "#{okay1 ? 'Sample' : '' }  #{okay2 ? 'FULLTEST' : ''} failed"
  exit(2)
end
