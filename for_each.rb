#!/usr/bin/env ruby
# installed git 1.8.4 via apt-get install git -t wheezy-backports und
# http://www.lyraphase.com/wp/projects/installing-latest-git-on-ubuntu-with-git-subtree-support/
# Don't use git-submodule or we will have problems when pushing/createing tags
require 'pp'
root = File.expand_path(File.dirname(__FILE__))
@user = 'ngiger'

unless ARGV.size >= 1
  puts "You must specify a cmd to execute"
  exit 2
end

userCmd = ARGV.join(' ')

puts "Will execute the following cmd in all reposrs:\n#{userCmd}"

repos = Dir.glob('*/.git')
repos.each{ 
  |repo|
  
  dir = File.dirname(repo)
  next if /modules/.match(dir)
  cmd = "cd #{File.join(root, dir)} && #{userCmd}"
  Dir.chdir(File.join(root, dir))
  puts "\n\n#{Dir.pwd}"
  unless system(userCmd)
    puts "Running #{cmd} failed!"
    exit 1
  end
}
