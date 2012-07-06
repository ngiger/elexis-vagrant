#!/usr/bin/env ruby
# creates a fileserver

FileServerRoot = '/opt/fileserver'
EclipseBaseURL = 'http://mirror.switch.ch/eclipse/technology/epp/downloads/release/indigo/SR2'
EclipseRelease = 'eclipse-rcp-indigo-SR2'
LibURL         = 'http://ftp.medelexis.ch/downloads_opensource/develop/'

require 'fileutils'

[ 'eclipse','jubula','latex', 'lib' ].each {
  |subdir|
    FileUtils.makedirs("#{FileServerRoot}/elexis/#{subdir}")
}

def getEclipse
  [ "win32.zip", "linux-gtk.tar.gz", "linux-gtk-x86_64.tar.gz", "macosx-cocoa-x86_64.tar.gz"].each {
    |variant|
      fileName = "#{EclipseRelease}-#{variant}"
      cmd = "wget --timestamping #{EclipseBaseURL}/#{fileName}"
      Dir.chdir("#{FileServerRoot}/elexis/eclipse")
      system(cmd)
  }
end

def getFloatflt
  cmd = "wget --timestamping http://mirror.switch.ch/ftp/mirror/tex/macros/latex/contrib/floatflt.zip"
  Dir.chdir("#{FileServerRoot}/elexis/latex")
  system(cmd)
end

def getJubula
  ['.exe', '.sh','.dmg'].each {
    |ext|
    cmd = "wget --timestamping https://s3.amazonaws.com/jubula/setup#{ext}"
    Dir.chdir("#{FileServerRoot}/elexis/jubula")
    system(cmd)
  }
end

def getLib
  puts "Don't know yet how to get
  ant-contrib.jar            fop-1.0-bin.zip      jdom.jar                org.eclipse.mylyn.wikitext.core.jar          scala-compiler.jar
  demoDB_elexis_2.1.5.4.zip  izpack-compiler.jar  medelexis-packager.jar  org.eclipse.mylyn.wikitext.textile.core.jar  scala-library.jar
  "
end

getEclipse
getFloatflt
getJubula
getLib