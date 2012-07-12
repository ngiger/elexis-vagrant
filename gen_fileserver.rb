#!/usr/bin/env ruby
# creates a fileserver

DstRoot        = '/opt/fileserver/elexis'
IndigoSR2      = 'eclipse-rcp-indigo-SR2' # Needed for Elexis 2.1.7
IndigoBaseURL  = 'http://mirror.switch.ch/eclipse/technology/epp/downloads/release/indigo/SR2'
MedelexisURL   = "http://ftp.medelexis.ch/downloads_opensource"
JunoBaseURL    = 'http://mirror.switch.ch/eclipse/technology/epp/downloads/release/juno/R'
Juno           = 'eclipse-rcp-juno'
LibURL         = "#{MedelexisURL}/develop"
JubulaURL      = "#{MedelexisURL}/jubula"
BoxesURL       = "#{MedelexisURL}/boxes"
LatexURL       = 'http://mirror.switch.ch/ftp/mirror/tex/macros/latex/contrib'
require 'fileutils'

[ 'eclipse','jubula','latex', 'lib', 'boxes' ].each {
  |subdir|
    FileUtils.makedirs("#{DstRoot}/elexis/#{subdir}")
}

def getFileFromBaseURL(target, url, files)
  files.each {
    |aFile|
    cmd = "wget --timestamping #{url}/#{aFile}"
    FileUtils.makedirs(target)
    Dir.chdir(target)
    puts "cd #{target} && #{cmd}"
    system(cmd)
  }
end

def getEclipse(target, url, release)
  [ "win32.zip", "linux-gtk.tar.gz", "linux-gtk-x86_64.tar.gz", "macosx-cocoa-x86_64.tar.gz"].each {
    |variant|
      fileName = "#{release}-#{variant}"
      getFileFromBaseURL(target, url, [fileName])
  }
end

# Use MedelexisURL as I cannot find old releases of Jubula on the Eclipse Download site
def getJubula(target, url, release, variants)
  variants.each {
    |ext|
    getFileFromBaseURL(target, url, ["#{release}#{ext}"])
  }
end

getFileFromBaseURL(DstRoot + '/latex', LatexURL, ['floatflt.zip'])
getEclipse(DstRoot + '/eclipse', IndigoBaseURL, IndigoSR2)
# getEclipse(DstRoot + '/eclipse', JunoBaseURL, Juno)
# getJubula('https://s3.amazonaws.com/jubula/','setup',  ['.exe', '.sh','.dmg'])
getJubula(DstRoot + '/jubula', JubulaURL, 'jubula_setup_5.2.00266',  ['.sh'])
getFileFromBaseURL(DstRoot + '/lib', LibURL,
		[
		'ant-contrib.jar',
                'demoDB_elexis_2.1.5.4.zip',
                'fop-1.0-bin.zip',
                'izpack-compiler.jar',
                'jdom.jar',
                'medelexis-packager.jar',
                'org.eclipse.mylyn.wikitext.core.jar',
                'org.eclipse.mylyn.wikitext.textile.core.jar',
                'scala-compiler.jar',
                'scala-library.jar'
               ])
getFileFromBaseURL(DstRoot + '/boxes', BoxesURL, ['Elexis-Squeeze-i386.box'])
