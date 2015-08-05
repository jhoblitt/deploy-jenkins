class jenkins_demo::profile::sensu::check::jenkins_slave {
  sensu::subscription { 'jenkins-slave': }

  #
  # jenkins-slave checks
  #
  sensu::check { 'jenkins-slave':
    command     => '/opt/sensu/embedded/bin/check-process.rb --file-pid /var/run/jenkins-slave/jenkins-slave.pid',
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-slave',
  }

  sensu::check { 'ganglia-gmond-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service gmond status\'',
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-slave',
  }
}
