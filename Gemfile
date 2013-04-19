source "http://rubygems.org"
# ruby '1.9.3'
gem "ruby-libvirt"
gem "vagrant"
# If you want a version newer than 1.0.7 you must add a line like
# gem "vagrant", github: "mitchellh/vagrant", tag: "v1.2.1"


# gem "veewee"
# gem 'vagrant-hiera'
# gem 'hiera-gpg'
# See https://github.com/rodjek/librarian-puppet/pull/87
# Until this commit is available via a version > 0.9.8 we need to use the git repo
gem 'librarian-puppet', :git => "git://github.com/rodjek/librarian-puppet.git"
group :test do
  gem 'mocha'
  gem 'rspec-puppet'
  gem 'puppet'
  gem 'watir'
end