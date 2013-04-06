# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby

class java($version = 6, $variant = 'openjdk', $hasJdk = false, $hasJre = true ) {
  case $variant {
    'sun':   { $jdkName = "sun-java${version}" }
    default: { $jdkName = "openjdk-${version}" }
  }
  case $hasJdk {
    true :  { package {"${jdkName}-jdk":
	      ensure => present
	    }
    }
  }
  case $hasJre {
    true :  { package {"${jdkName}-jre":
	      ensure => present
	    }
    }
  }
  notify { "variant: $variant $version -> $jdkName ${jdkName}-jdk": }
}

include java