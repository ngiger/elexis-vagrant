# We want Ruby 1.9.3 or 2.1.2
source "http://rubygems.org"
if RUBY_VERSION == '1.9.3'
  ruby '1.9.3'
else
  ruby '2.1.2'
end

gem_version = `gem --version`
unless /^2/.match(gem_version) or /1\.8/.match(gem_version)
  puts "We need gem in a version >= 1.8 is  #{gem_version}"
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

