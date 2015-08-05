class jenkins_demo::profile::sensu::check::jenkins_master {
  sensu::subscription { 'jenkins-master': }

  #
  # jenkins-master checks
  #

  # checks port 8080 bypassing the nginx reverse proxy
  sensu::check { 'jenkins-health':
    command     => '/opt/sensu/embedded/bin/check-jenkins-health.rb',
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-master',
  }

  sensu::check { 'selinux enabled':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -s 0 -c \'selinuxenabled\'',
    interval    => 3600,
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-master',
  }

  sensu::check { 'ganglia-gmetad-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service gmetad status\'',
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-master',
  }

  sensu::check { 'php-fpm-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service php-fpm status\'',
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-master',
  }

  sensu::check { 'nginx-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service nginx status\'',
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-master',
  }

  sensu::check { 'jenkins-service':
    command     => '/opt/sensu/embedded/bin/check-process.rb --file-pid /var/run/jenkins.pid',
    refresh     => 15,
    handlers    => 'hipchat',
    subscribers => 'jenkins-master',
  }
}
