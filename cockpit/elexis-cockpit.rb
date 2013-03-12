#!/usr/bin/env ruby
# encoding: utf-8

# from http://net.tutsplus.com/tutorials/ruby/singing-with-sinatra/
# HomePage http://www.sinatrarb.com/
# Abgesicherten Bereich https://github.com/integrity/sinatra-authorization
# ActiveRecord migrations: http://www.sinatrarb.com/faq.html#ar-migrations
# Add erubis for auto escaping HTML http://www.sinatrarb.com/faq.html#auto_escape_html
# Übersetzung: https://github.com/ai/r18n https://github.com/sinefunc/sinatra-i18n
# Beispiel unter https://github.com/ai/r18n/tree/master/sinatra-r18n
# Progressbar https://github.com/blueimp/jQuery-File-Upload
#   console: https://github.com/paul/progress_bar
# https://github.com/sinefunc/sinatra-support
# -percentage = (Time.now.to_i.modulo(500))/5
#  %div.progress.progress-striped.active
#   %div.bar{:style => "width: #{percentage}%;"}

# http://ididitmyway.herokuapp.com/past/2010/4/18/using_active_record_in_the_console/
# https://github.com/janko-m/sinatra-activerecord
# Nächster Artikel ist sehr gut!
# http://danneu.com/posts/15-a-simple-blog-with-sinatra-and-active-record-some-useful-tools/

# Features: 
#   Freier Platz auf Festplatte auf lokalem Rechner
#  Backup anstossen, 

# TODO: für Elexis-Cockpit
    # Freier Platz auf Festplatte (je Server und Backup)
    # Backup gelaufen (gestern, vorgestern), Zeit und Grösse, evtl. Änderungen plausibilisieren?
    # Backup in Test-DB einlesen
    # Backup auf externe Festplatte
    # Backup-Server online? à jour?
    # Neue (Med)Elexis-Version installieren, aktivieren, 
    # Auf alte Version zurückschalte
    # Dito für Linux, Mac/Windows unter Samba??
    # Artikelstamm/Tarmed (wann letztes Update). Aktuelleste Versionen?
# Später
    # Smartmonitor status
    # nagios
    # Updates von elexis-vagrant?
require 'rubygems'
require 'sinatra'  
require 'data_mapper'
require 'builder'
require 'sys/filesystem'
require 'redcloth'
require 'hiera'
require 'action_view'
require 'socket'
include Sys
include ActionView::Helpers::DateHelper
require 'erubis'
# set :erb, :escape_html => true   # dann wird alles home.erb escaped!

  # Display information about a particular filesystem.
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")  
  
helpers do  
  include Rack::Utils  
  alias_method :h, :escape_html  
end  

def get_hiera(key)
  local_yaml_db     = File.join(File.dirname(__FILE__), 'local_config.yaml')
  local_hiera_conf  = File.join(File.dirname(__FILE__), 'local_hiera.yaml')
  if File.exists?(local_yaml_db) and false
    scope = YAML.load_file(local_yaml_db)
    puts "#{local_hiera_conf}: loaded values from #{local_yaml_db} looking for #{key}"
    hiera = Hiera.new(:config =>local_hiera_conf)
  else
    scope = 'path_to_no_file'
    hiera = Hiera.new(:config => "/etc/puppet/hiera.yaml")
    puts "/etc/puppet/hiera.yam: hiera for #{scope}" 
  end
  value = hiera.lookup(key, 'unbekannt', scope)
  puts "hiera for #{key} got #{value}" # if $VERBOSE
  value
end

def get_db_backup_info(which_one)
  key_dir   = "::db::backup::dir"
  key_name  = "::db::backup::name"
  backup_dir = get_hiera(key_dir)
  db_main   =  get_hiera(key_name)
  
  maxHours  = 25
  unless (backup_dir and db_main)
    backup_okay = "Kein #{which_one.capitalize}-Datenbank-Backup definiert"
    backup_hover = "Hiera #{key_dir} oder #{key_name} schlug fehlt"
  else
    search_path ="#{backup_dir}/#{which_one}/*"
    backups = Dir.glob(search_path)
    if  backups.size == 0
      backup_okay = "Keine Backup_Dateien via '#{search_path}' gefunden"
      backup_hover = "Fehlschlag. Bitte beheben Sie das Problem"
    else
      neueste = backups[0]
      modificationTime = File.mtime(neueste)
      human = distance_of_time_in_words(Time.now, modificationTime)
      if (Time.now - modificationTime < maxHours*60*60)        
        backup_okay  = "#{which_one.capitalize}-Backup okay"
        backup_hover = "#{backups.size} Backups vorhanden. Neueste #{neueste}  #{File.size(neueste)} Bytes erstellt vor #{human}"
      else
        backup_okay = "Neueste Backup-Datei '#{neueste}' von vor #{human} ist älter als #{maxHours} Stunden!"
        backup_hover = "Fehlschlag. Fand #{backups.size} Backup-Dateien via '#{search_path}'"
      end
    end
  end
  return backup_okay, backup_hover
end

def getInstalledElexisVersions(elexisBasePaths = [ '/srv/elexis', '/usr/share/elexis', "#{ENV['HOME']}/elexis/bin" ])
  versions = Hash.new
  elexisBasePaths.each{
    |path|
      search_path = "#{path}/*/elexis"
      puts "#{path}: search_path ist #{search_path}"
      iniFiles = Dir.glob(search_path)
      puts iniFiles
      iniFiles.each{
        |iniFile|
          version  = File.basename(File.dirname(iniFile))  # .sub(/elexis-/, ''))
          puts "#{iniFile} version #{version}"
          versions[version] = File.dirname(iniFile) unless versions[version]
                   }
  }
  versions.sort.reverse
end

def getMountInfo(mounts = Hash.new)
  part_max_fill = 85  
  mount_points = Filesystem.mounts.select{|m| not /tmp|devpts|proc|sysfs|rootfs|pipefs|binfmt_misc/.match(m.mount_type) }
  mount_points.each do |m|
    mount_info = Hash.new
    mp =  Filesystem.stat(m.mount_point); 
    percentage = 100-((mp.blocks_free.to_f/mp.blocks.to_f)*100).to_i 
    mount_info[:mount_point] = m.mount_point
    mount_info[:type] = m.mount_type
    mount_info[:percentage]  = percentage
    mount_info[:background]  = percentage < part_max_fill ? '#0a0' : '#FF0000'
    mounts[m.mount_point] = mount_info
  end
  mounts
end

def getDbConfiguration(info = Hash.new)
  info[:dbServer] = get_hiera('::db::server')
  info[:dbBackup] = get_hiera('::db::backup')
  info[:dbFlavors] = ['h2', 'mysql', 'postgresql' ]
  info[:dbHosts]  = [ 'localhost' ]
  info[:dbHosts] << :server if info[:server]
  info[:dbHosts] << 'backup' if info[:backup]
  info[:dbPorts]  = [ get_hiera('::db::port') ]
  info[:dbUsers]  = [ get_hiera('::db::user')]
  info[:dbNames]  = [ get_hiera('::db::main')]
  info
end

def getBackupInfo(backup = Hash.new)
  
  if get_hiera("elexis:mysql:included")
    backup[:okay], backup[:backup_tooltip] = get_db_backup_info('mysql')
    backup[:script] = '/usr/local/sbin/mysqlbackup.sh'
  elsif get_hiera("elexis:postgresql:included")
    backup[:okay], backup[:tooltip] = get_db_backup_info('postgresql')
    backup[:script] = '/usr/local/bin/pg_dump_elexis.rb'
  else
    backup[:okay]        = "Weder MySQL noch PostgreSQL definiert. Probleme mit dem Setup!!  "
    backup[:tooltip]     = nil
    backup[:setup_error] = true
  end
  backup
end

def getSystemInfo
  info          = getDbConfiguration
  info[:hostname] = Socket.gethostname
  info[:mounts] = getMountInfo
  info[:backup] = getBackupInfo
  info
end

configure do
  set :info, getSystemInfo
  set :batch, [2]
end

# Some helper links. Should allow use to easily get values from server/backup
get '/info.yaml' do  
  getSystemInfo.to_yaml.gsub("\n",'<br>').gsub(' ', '&nbsp;')
end

get '/info.json' do  
  getSystemInfo.to_json.gsub("\n",'<br>').gsub(' ', '&nbsp;')
end

class BatchRunner
  attr_accessor :finished, :result, :endTime, :workThread, :updateThread
  attr_reader   :startTime, :batchFile, :title, :info
  $info = nil
  
  def initialize(batchFile, 
                 title="#{File.basename(batch_file)} ausführen",
                 okMsg="#{File.basename(batch_file)} erfolgreich beendet",
                 errMsg="#{File.basename(batch_file)} mit Fehler beendet")
    @title      = title
    @batchFile  = batchFile
    @finished   = false
    @okMsg      = okMsg
    @errMsg     = errMsg
  end
  
  def runBatch
    # cannot be run using shotgun! Please call it using ruby elexis-cockpit.rub
    back2home = "<br> <br><a href='/'>Zurück zur Hauptseite</a> <br>"
    if @batchFile.length < 2 or not File.exists?(@batchFile) or not File.executable?(@batchFile)
      "#{Time.now}: Fehler in der Konfiguration. Datei '#{@batchFile}' kann nicht ausgeführt werden" + back2home
    else
      @startTime = Time.now unless @startTime
      @workThread = Thread.new do
        @result = system(@batchFile)
        @endTime = Time.now
        @finished = true
      end if not @finished and not @workThread
      
      if @finished
        diffSeconds = (@endTime-@startTime).to_i
        cleartext = @result ? @okMsg : @errMsg
        "#{Time.now}: '#{@batchFile}' beendet (nach #{diffSeconds} Sekunden)." + back2home + cleartext
      else
        diffSeconds = (Time.now-@startTime).to_i
        "#{Time.now}: '#{@batchFile}' ist seit #{diffSeconds} Sekunden am laufen.<br>Seite neu laden, um zu sehen, ob das Programm weiterhin läuft."
      end
    end
  end
end

get '/' do
  @info = getSystemInfo
  settings.info = @info
  @title = 'Übersicht'
  settings.batch = BatchRunner.new(settings.info[:backup][:script], 
                                    'Datenbank-Sicherung gestartet',
                                    'Datenbank-Sicherung erfolgreich beendet',
                                    'Datenbank-Sicherung fehlgeschlagen!!!')
  erb :home
end  

get '/start' do
  @title = 'Elexis starten'
  @elexis_versions = getInstalledElexisVersions
  erb :start
end

post '/start' do
  cmd = "nice #{params[:version]}/elexis " # +
      # "-Dch.elexis.dbUser=#{params[:dbUser]} -Dch.elexis.dbPw=#{params[:dbPw]} " +
      # "-Dch.elexis.dbFlavor=#{params[:dbFlavor]}  -Dch.elexis.dbSpec=jdbc:#{params[:dbFlavor]}://#{params[:dbHost]}:#{params[:dbPort]}/#{params[:dbName]}"
  # Could also query for -Dch.elexis.username=test -Dch.elexis.password=test 
  file = Tempfile.new('foo')
  file.puts("#!/bin/bash -v")
  file.puts(cmd + " &") # run in the background
  file.close
  File.chmod(0755, file.path)
  settings.batch = BatchRunner.new(file.path, 
                                    'Elexis starten',
                                    'Elexis erfolgreich gestartet',
                                    'Elexis konnte nicht gestartet werde')

  redirect '/elexisStarted'    
end 

get '/elexisStarted' do
  # cannot be run using shotgun! Please call it using ruby elexis-cockpit.rub
  @title = settings.batch.title
  settings.batch.runBatch  
end

def didNotWork
  puts cmd
  settings.batch.runBatch

  Thread.new do
    puts "Starting thread"; s
    system(cmd); 
    puts "#{cmd} finished" 
  end
  sleep 0.1
  puts "After creating thread"  
  redirect '/'    
end

get '/startDbBackup' do
  # cannot be run using shotgun! Please call it using ruby elexis-cockpit.rub
  @title = settings.batch.title
  settings.batch.runBatch
end

post '/startDbBackup' do
  redirect '/startDbBackup'    
end 

