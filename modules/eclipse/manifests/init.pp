class eclipse($version = "3.7.2*") {
  package { "eclipse":
    ensure => $version,
  }
}
