# We want Ruby 1.9.3 or 2.1.2
source "http://rubygems.org"
ruby '1.9.3'
ruby '2.1.2'

gem_version = `gem --version`
unless /^2/.match(gem_version)
  puts "We need gem in a version >= 2 is  #{gem_version}"
  exit 2
end

if false
  # we now use vagrant installed from deb package
  gem "vagrant"
  gem "vagrant-docker"
  group :plugins do
    gem "vagrant-docker"
  end
end

gem 'bundler',            '>=1.6.0'
gem 'puppet',             '>=3.6.0'
gem 'librarian-puppet',   '>=1.0.0'
