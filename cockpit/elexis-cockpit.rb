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

# https://github.com/djberg96/sys-filesystem
# require 'sys/filesystem'
# include Sys
# sprintf("Partition: %s %2.2f%% frei ", x.path, (x.blocks_free.to_f/x.blocks.to_f)*100)

require 'rubygems'
require 'sinatra'  
require 'data_mapper'
require 'builder'
require 'sys/filesystem'
require 'redcloth'

include Sys
   
  # Display information about a particular filesystem.
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")  
  
class Note  
  include DataMapper::Resource  
  property :id, Serial  
  property :content, Text, :required => true  
  property :complete, Boolean, :required => true, :default => false  
  property :created_at, DateTime  
  property :updated_at, DateTime  
end  
  
DataMapper.finalize.auto_upgrade!  

    helpers do  
        include Rack::Utils  
        alias_method :h, :escape_html  
    end  


    get '/' do  
      @notes = Note.all :order => :id.desc  
      @title = 'Übersicht'  
      # textile :elexis, :layout_engine => :erb  # will evaluate views/home.erb
      erb :home
      # Filesystem.mounts{ |mount| p mount }
    end  

post '/' do  
  puts "Taking note"
  n = Note.new  
  n.content = params[:content]  
  n.created_at = Time.now  
  n.updated_at = Time.now  
  n.save  
  puts "redirecting"
  redirect '/'  
  puts "redirect done"
end  

    get '/rss.xml' do  
        @notes = Note.all :order => :id.desc  
        builder :rss  
    end  


    get '/:id' do  
      @note = Note.get params[:id]  
      @title = "Edit note ##{params[:id]}"  
      erb :edit  
    end  
    
    put '/:id' do  
      n = Note.get params[:id]  
      n.content = params[:content]  
      n.complete = params[:complete] ? 1 : 0  
      n.updated_at = Time.now  
      n.save  
      redirect '/'  
    end  
    
    get '/:id/delete' do  
      @note = Note.get params[:id]  
      @title = "Confirm deletion of note ##{params[:id]}"  
      erb :delete  
    end  
    
    delete '/:id' do  
      n = Note.get params[:id]  
      n.destroy  
      redirect '/'  
    end  

    get '/:id/complete' do  
      n = Note.get params[:id]  
      n.complete = n.complete ? 0 : 1 # flip it  
      n.updated_at = Time.now  
      n.save  
      redirect '/'  
    end  


# Cockpit
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