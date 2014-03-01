
class { 'apache':
      default_mods        => false,
      default_confd_files => false,
      mpm_module => apache::mod::worker,
    }
apache::vhost { 'ssl.example.com':
      port    => '443',
      docroot => '/var/www/ssl',
      ssl     => true,
    }
apache::vhost { 'subdomain.example.com':
     # ip      => '127.0.0.1',
      port    => '80',
      docroot => '/var/www/subdomain',
}

apache::mod { 'ldap': }