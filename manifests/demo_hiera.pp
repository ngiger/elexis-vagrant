# see also https://github.com/ripienaar/hiera-puppet#readme
# https://github.com/puppetlabs/hiera
# http://docs.puppetlabs.com/hiera/1/variables.html
# https://ttboj.wordpress.com/2013/02/20/automatic-hiera-lookups-in-puppet-3-x/?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+planetpuppet+%28Planet+Puppet%29
# https://puppetlabs.com/blog/first-look-installing-and-using-hiera/
node "elexisDev32bit" {
   include ntp_demo::config
}
