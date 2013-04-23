# configure mail for sending

class { 'git': }
class elexis::mail(
  $email_user     = hiera('elexis::mail::user',      'put your username   into /tmp/hiera-data/private/config.yaml'),
  $email_password = hiera('elexis::mail::password',  'put your password   into /tmp/hiera-data/private/config.yaml'),
  $mail_smtp_host = hiera('elexis::mail::smtp_host', 'put your smtp_host  into /tmp/hiera-data/private/config.yaml'),
  
) {
  $mail_package = 'ssmtp'
  file { '/etc/puppet/private':
    ensure => directory,
    owner => 'root',
    group => 'root',
    mode => '0644',
  }
  
  file { '/etc/ssmtp/revaliases':
  content => "# Managed by puppet elexis/manifests/mail.pp
root:${email_user}
vagrant:${email_user}
",
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => Package[$mail_package],
}
 
  package{"$mail_package": }
  file { '/etc/ssmtp/ssmtp.conf':
    content => "# Managed by puppet elexis/manifests/mail.pp
root=${email_user}
mailhub=${mail_smtp_host}
rewriteDomain=ngiger.dyndns.org
hostname=${mail_smtp_host}
UseSTARTTLS=YES  
AuthUser=${email_user}
AuthPass=${email_password}
FromLineOverride=Yes
",
    owner => 'root',
    group => 'root',
    mode => '0644',    
    require => Package[$mail_package],
}
  
# setup some mail aliases
  mailalias { "root":
    ensure    => present,
    recipient => "$email_user",
    provider  => augeas,
  }
  

}
