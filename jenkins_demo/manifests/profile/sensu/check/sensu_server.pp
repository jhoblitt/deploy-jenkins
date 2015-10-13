class jenkins_demo::profile::sensu::check::sensu_server {
  #
  # sensu-server checks
  #
  $www_host = hiera('www_host', 'jenkins-master')
  $uchiwa_www_host = hiera('uchiwa_www_host', 'jenkins-sensu')

  sensu::check { 'jenkins-http-https-redirect':
    command     => "/opt/sensu/embedded/bin/check-http.rb --url http://${www_host}/ --redirect-to https://${www_host}/",
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'jenkins-https':
    command     => "/opt/sensu/embedded/bin/check-http.rb --url https://${www_host}/",
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'jenkins-https-cert-valid':
    command     => "/opt/sensu/embedded/bin/check-https-cert.rb --url https://${www_host}/ -w 90 -c 45",
    interval    => 3600,
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'jenkins-ssllabs':
    command     => "/opt/sensu/embedded/bin/check-ssl-qualys.rb -d ${www_host} -w A+ -c A",
    interval    => 86400,
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'uchiwa-http-https-redirect':
    command     => "/opt/sensu/embedded/bin/check-http.rb --url http://${uchiwa_www_host}/ --redirect-to https://${uchiwa_www_host}/",
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'uchiwa-https':
    # oauth2_proxy returns http 403 with the github login button page
    command     => "/opt/sensu/embedded/bin/check-http.rb --response-code 403 --url https://${uchiwa_www_host}/",
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'uchiwa-https-cert-valid':
    command     => "/opt/sensu/embedded/bin/check-https-cert.rb --url https://${uchiwa_www_host}/ -w 90 -c 45",
    interval    => 3600,
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'uchiwa-ssllabs':
    command     => "/opt/sensu/embedded/bin/check-ssl-qualys.rb -d ${uchiwa_www_host} -w A+ -c A",
    interval    => 86400,
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'ganglia-web':
    command     => "/opt/sensu/embedded/bin/check-http.rb --url https://${www_host}/ganglia/",
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'rabbitmq-alive':
    command     => '/opt/sensu/embedded/bin/check-rabbitmq-alive.rb --vhost :::vhost|sensu::: --username :::username|sensu::: --password :::password:::',
    subscribers => 'sensu-server',
    custom       => {
      'password'   => 'sensutest',
    },
    standalone  => false,
  }

  sensu::check { 'redis':
    command     => '/opt/sensu/embedded/bin/check-redis-info.rb',
    subscribers => 'sensu-server',
    standalone  => false,
  }

  # we can not use the uchiwa init script to test for aliveness
  # https://github.com/sensu/uchiwa-build/issues/23
  sensu::check { 'uchiwa-service':
    command     => '/opt/sensu/embedded/bin/check-process.rb --file-pid /var/run/uchiwa.pid',
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'sensu-api-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service sensu-api status\'',
    subscribers => 'sensu-server',
    standalone  => false,
  }

  sensu::check { 'sensu-server-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service sensu-server status\'',
    subscribers => 'sensu-server',
    standalone  => false,
  }
}
