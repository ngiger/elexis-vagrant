class eclipse($version = "3.7.2-1") {
  package { "eclipse":
    ensure => $version,
  }
}
