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
# http://samuelstern.wordpress.com/2012/11/28/making-a-simple-database-driven-website-with-sinatra-and-heroku/
# http://guides.rubyonrails.org/migrations.html
# http://ididitmyway.herokuapp.com/past/2010/4/18/using_active_record_in_the_console/
# https://github.com/janko-m/sinatra-activerecord
# Nächster Artikel ist sehr gut!
# http://danneu.com/posts/15-a-simple-blog-with-sinatra-and-active-record-some-useful-tools/
# https://github.com/zdennis/activerecord-import/wiki
# http://stackoverflow.com/questions/3704065/how-to-import-data-into-rails
# http://stackoverflow.com/questions/8476769/import-from-csv-into-ruby-array-with-1st-field-as-hash-key-then-lookup-a-field  
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
    # Display information about a particular filesystem.

require 'sinatra'  
require 'data_mapper'
require 'builder'
require 'redcloth'
require 'hiera'
require 'socket'
# to display human readable time difference
require 'action_view'
include ActionView::Helpers::DateHelper

require 'sinatra/base'
require File.join(File.dirname(__FILE__), 'lib', 'elexis_helpers')

class ElexisCockpit < Sinatra::Base
  register Sinatra::ElexisHelpers
  @batch = nil
  
  helpers do  
    include Rack::Utils  
    alias_method :h, :escape_html  
  end  

  configure do
    set :port,  9393 # same as shotgun
    set :info,  getSystemInfo
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
    settings.set(:info, @info)
    @title = 'Übersicht'
    settings.set(:batch, nil)
    erb :home
  end  

  get '/start' do
    @title = 'Elexis starten'
    @elexis_versions = getInstalledElexisVersions
    erb :start
  end

  post '/start' do
    puts "params = #{params.inspect}"
    version = params[:version]
    redirect "/runElexis?version=#{version}"
  end 

  get '/runElexis' do
    # cannot be run using shotgun! Please call it using ruby elexis-cockpit.rub
    puts "#{request.path_info}: version #{params[:version]}"
    unless settings.batch
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
    end
    @title = settings.batch.title
    settings.batch.runBatch
  end

  get '/runDbBackup' do
    # cannot be run using shotgun! Please call it using ruby elexis-cockpit.rub
    puts "#{request.path_info}: #{settings.batch.inspect}"
    unless settings.batch
      settings.batch = BatchRunner.new(settings.info[:backup][:script], 
                                        'Datenbank-Sicherung gestartet',
                                        'Datenbank-Sicherung erfolgreich beendet',
                                        'Datenbank-Sicherung fehlgeschlagen!!!')
    end
    @title = settings.batch.title
    settings.batch.runBatch
  end

  post '/runDbBackup' do
    redirect '/runDbBackup'    
  end 

  get '/formatEncrypted' do
    puts "#{request.path_info}"
    @title = 'Verschlüsselte Partition erstellen'
    @candidates = Hash.new
    @candidates = getPossibleExternalDiskDrives
    puts @candidates.inspect
    erb :formatEncrypted
  end  
  
  post '/formatEncrypted' do
    @title = 'Verschlüsselte Partition erstellen'
    @candidates = Hash.new
    @candidates = getPossibleExternalDiskDrives
    erb :formatEncrypted
    # call /usr/local/bin/backup_encrypted.rb --device-name ausgewählt --init
    # Batch laufen lassen
  end
  
  post '/runFormatting' do
    puts "#{request.path_info}: params #{params}"
    device = params[:device]
    settings.set(:batch, nil)
    redirect "/runFormatting?device=#{device}"
  end  # start the server if ruby file executed directly

  get '/runFormatting' do
    # cannot be run using shotgun! Please call it using ruby elexis-cockpit.rub
    unless settings.batch
      cmd = "echo #{get_hiera('::hd::external::format_and_encrypt')} -init --device #{params[:device]}; echo done "  
      file = Tempfile.new('foo')
      file.puts("#!/bin/bash -v")
      file.puts(cmd) # Wait til finished
      file.close
      File.chmod(0755, file.path)
      settings.batch = BatchRunner.new(file.path, 
                                        'Externe Festplatte formattieren und verschlüsseln',
                                        'Externe Festplatte erfolgreich verschlüsselt',
                                        'Externe Festplatte konnte nicht formattieren werden')
    end
    @title = settings.batch.title
    settings.batch.runBatch
  end  # start the server if ruby file executed directly
  
  run! if app_file == $0
end
