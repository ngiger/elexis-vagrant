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

# TODO: für Elexis-Cockpit
    # Freier Platz auf Festplatte (je Server und Backup)
    # Backup gelaufen (gestern, vorgestern), Zeit und Grösse, evtl. Änderungen plausibilisieren?
    # Backup anstossen, Backup in Test-DB einlesen
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
  scope = 'path_to_no_file'
  hiera = Hiera.new(:config => "/etc/puppet/hiera.yaml")
  value = hiera.lookup(key, nil, scope)
  puts "hiera for #{key} got #{value}" # if $VERBOSE
  value
end

#I18n.locale = "de"


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

get '/' do  
  @mount_points = Filesystem.mounts.select{|m| not /tmp|devpts|proc|sysfs|rootfs|pipefs|binfmt_misc/.match(m.mount_type) }
  @title = 'Übersicht'
  @hostname = Socket.gethostname
  @server   = get_hiera('::db::server')
  @backup   = get_hiera('::db::backup')
  @part_max_fill = 85
  if get_hiera("elexis:mysql:included")
    @backup_okay, @backup_tooltip = get_db_backup_info('mysql')
    $backup_script = '/usr/local/sbin/mysqlbackup.sh'
  elsif get_hiera("elexis:postgresql:included")
    @backup_okay, @backup_tooltip = get_db_backup_info('postgresql')
    $backup_script = '/usr/local/bin/pg_dump_elexis.rb'
  else
    @backup_okay    = "Weder MySQL noch PostgreSQL definiert. Probleme mit dem Setup!!  "
    @backup_tooltip = nil
    @backup_setup_error = true
  end
  @dbFlavors = ['h2', 'mysql', 'postgresql' ]
  @dbHosts = [ 'localhost' ]
  @dbHosts << @server if @server
  @dbHosts << @backup if @backup
  @dbPorts  = [ 3306 ]      # cannot be changed at the moment
  @dbUsers  = [ 'elexis' ]  # cannot be changed at the moment
  @dbNames  = [ 'elexis' ]  # cannot be changed at the moment
  $finished = false
  $result = false
  $startTime = nil
  erb :home
end  

get '/start' do
  @title = 'Elexis starten'
  @elexis_versions = getInstalledElexisVersions
  erb :start
end

post '/start' do    
  cmd = "nice #{params[:version]}/elexis "+
      "-Dch.elexis.dbUser=#{dbUser[:user]} -Dch.elexis.dbPw=#{params[:dbPw]} " +
      "-Dch.elexis.dbFlavor=#{dbFlavor}  -Dch.elexis.dbSpec=jdbc:#{params[:dbFlavor]}://#{params[:dbHost]}:#{params[:dbPort]}/#{params[:dbName]}"
  # Could also query for -Dch.elexis.username=test -Dch.elexis.password=test 
  Thread.new { `#{cmd}` }
  redirect '/'    
end 

get '/startDbBackup' do
  $backup_script = '' unless $backup_script
  puts "#{Time.now} startDbBackup using '#{$backup_script}'"
  back2home = "<br> <br><a href='/'>Zurück zur Hauptseite</a> <br>"
  @title = 'Datenbank-Sicherung gestartet'
  if $backup_script.length < 2 or not File.exists?($backup_script) or not File.executable?($backup_script)
    "Fehler in der Konfiguration. Datei '#{$backup_script}' kann nicht ausgeführt werden" + back2home
  else
    $startTime = Time.now unless $startTime
    $workThread = Thread.new do # trivial example work thread
      puts "#{Time.now}: Starting thread  #{$backup_script}"
      $result = system($backup_script)
      puts "#{Time.now}: thread #{$backup_script} finished"
      $endTime = Time.now
      $finished = true
    end unless defined?($workThread)

    if $finished
      diffSeconds = ($endTime-$startTime).to_i
      cleartext = $result ? "Backup erfolgreich " : "Backup fehlgeschlagen!!!"
      puts cleartext
      "#{Time.now}: Datensicherung via #{$backup_script} beendet (nach #{diffSeconds} Sekunden)." + back2home + cleartext
    else
      diffSeconds = (Time.now-$startTime).to_i
      "#{Time.now}: Seit #{diffSeconds} Sekunden ist '#{$backup_script}'  am arbeiten.<br>Seite neu laden, um zu sehen, ob die Datensicherung noch am laufen ist."
    end
  end
end

post '/startDbBackup' do    
  redirect '/startDbBackup'    
end 

