include jenkins
include elexis::common

elexis::download_eclipse_version{'eclipse-rcp-juno':
  baseURL => "${elexis::common::elexisFileServer}/eclipse",
}
elexis::download_eclipse_version{'eclipse-rcp-indigo-SR2':
  baseURL => "${elexis::common::elexisFileServer}/eclipse",
}
