#!/usr/bin/env ruby
# encoding: utf-8

module Sinatra
  module ElexisHelpers
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

  def getDbConfiguration
    info = Hash.new
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

  def getBackupInfo
    backup = Hash.new    
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
  end
  # this will only affect Sinatra::Application
  register ElexisHelpers
end
