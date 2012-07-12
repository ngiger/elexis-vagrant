# kate: replace-tabs on; indent-width 2; indent-mode cstyle; syntax ruby
# Here we setup a few elexis related jenkins job configuration files
# TODO: Jubula needs a 32-bit Java (and a 32-bit Elexis)
# TODO: 32-bit java, eg. sudo apt-get install openjdk-6-jdk:i386 openjdk-6-jre-headless:i386

define elexis::jenkins_elexis(
  $branch,
  $baseURL = $elexisBaseURL,
  $archieURL = "http://archie.googlecode.com/svn/archie/ch.unibe.iam.scg.archie/branches/elexis-2.1",
  $eclipseVersion = 'eclipse-rcp-indigo-SR2',
) {
  include jenkins
  include elexis::common
  include elexis::jenkins_commons
  include elexis::jenkins_slave

  File{
    owner   =>       $jenkins::jenkinsUser,
    group   =>       $jenkins::jenkinsUser,
  }
  
  if (!defined(Elexis::Download_eclipse_version[$eclipseVersion])) {
    elexis::download_eclipse_version{$eclipseVersion:
      baseURL => "${elexis::common::elexisFileServer}/eclipse",
    }
    elexis::eclipse_plugins{$eclipseVersion:
    }
  }

  jenkins::job{"elexis-${branch}-poll-base":
      branch    	   => $branch,
      pollURL        => "${baseURL}/elexis-base",
      pollType       => 'mercurial',
      configTemplate => "jenkins/poll_config.erb",
      childProjects  => "elexis-${branch}-ant",
    }

  jenkins::job{"elexis-${branch}-poll-addons":
      branch    	   => $branch,
      pollURL        => "${baseURL}/elexis-addons",
      pollType       => 'mercurial',
      configTemplate => "jenkins/poll_config.erb",
      childProjects  => "elexis-${branch}-ant",
    }

  jenkins::job{"elexis-${branch}-poll-archie":
      branch         => $branch,
      pollURL        => $archieURL,
      pollType       => 'svn',
      configTemplate => "jenkins/poll_config_svn.erb",
      childProjects  => "elexis-${branch}-ant",
    }

  $antJobName = "elexis-${branch}-ant"
  jenkins::job{$antJobName:
      branch         => $branch,
      pollURL        => 'https://bitbucket.org/ngiger/elexis-bootstrap',
      pollType       => 'mercurial',
      configTemplate => "elexis/jenkins/ant_config.erb",
      childProjects  => "elexis-${branch}-jubula",
    }

  $install_jar_project = "elexis-${branch}-ant"
  $jubulaJobName = "elexis-${branch}-jubula"
  jenkins::job{"$jubulaJobName":
      branch         => 'jubula-1.1',
      pollURL        => 'https://bitbucket.org/ngiger/jubula-elexis',
      pollType       => 'mercurial',
      configTemplate => "elexis/jenkins/jubula_config.erb",
    }

  # To be able to run jubula, we need the patched version of run_jenkins.rb
  $jobDir      = "${jenkins::jenkinsRoot}/jobs/${jubulaJobName}"
  notify{ "schon Jubula jubulaJobName ist ${jubulaJobName} jobDir ${jobDir}": }
  file {"${jobDir}/vagrant_runs_jenkins.rb":
    ensure => present,
    mode   => 0755,
    content => template("elexis/jenkins/vagrant_runs_jenkins.erb"),
    require => [User[$jenkins::jenkinsUser], Jenkins::Job[$jubulaJobName]],
  }

  # speed up building and save space linking to common for the ant task
  file { "/var/lib/jenkins/jobs/${antJobName}/downloads":
    ensure => link, # so make this a link
    target => "${jenkins::jenkinsRoot}/downloads",
  }

  file { "/var/lib/jenkins/jobs/${antJobName}/workspace/lib":
    ensure => link, # so make this a link
    target => "/var/lib/jenkins/jobs/${antJobName}/lib",
    require => File["/var/lib/jenkins/jobs/${antJobName}/workspace"],
  }
  file { "/var/lib/jenkins/jobs/${antJobName}/workspace":
    ensure => directory, # so make this a link
  }


}
