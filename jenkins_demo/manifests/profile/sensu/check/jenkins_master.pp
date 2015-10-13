class jenkins_demo::profile::sensu::check::jenkins_master {
  #
  # jenkins-master checks
  #

  # checks port 8080 bypassing the nginx reverse proxy
  sensu::check { 'jenkins-health':
    command     => '/opt/sensu/embedded/bin/check-jenkins-health.rb',
    subscribers => 'jenkins-master',
    standalone  => false,
  }

  sensu::check { 'selinux enabled':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -s 0 -c \'selinuxenabled\'',
    interval    => 3600,
    subscribers => 'jenkins-master',
    standalone  => false,
  }

  sensu::check { 'ganglia-gmetad-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service gmetad status\'',
    subscribers => 'jenkins-master',
    standalone  => false,
  }

  sensu::check { 'php-fpm-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service php-fpm status\'',
    subscribers => 'jenkins-master',
    standalone  => false,
  }

  sensu::check { 'nginx-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service nginx status\'',
    subscribers => 'jenkins-master',
    standalone  => false,
  }

  sensu::check { 'jenkins-service':
    command     => '/opt/sensu/embedded/bin/check-process.rb --file-pid /var/run/jenkins.pid',
    subscribers => 'jenkins-master',
    standalone  => false,
  }
}
