# Here we define all needed stuff to bring up a Wiki for an Elexis practice

class { 'git': }
class elexis::rvm 
(
  # nothing to be configured at the moment
)
inherits elexis::common {
  include rvm
  
  rvm_system_ruby {
    'ruby-1.9.2-p320':
      ensure => 'present',
      default_use => true;
    'ruby-2.0.0-p0':
      ensure => 'present',
      default_use => false;
  }
  
}

