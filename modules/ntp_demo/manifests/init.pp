# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
class ntp_demo::config($ntpservers = hiera("ntpservers", ["ntp1.example.com", "ntp2.example.com"]), 
   $ntpinfo = hiera("ntpinfo", 'default ntp info')) {
   file{"/etc/ntp.conf.dummy":
       content => template("ntp_demo/mytemplate.erb")
   }
}

