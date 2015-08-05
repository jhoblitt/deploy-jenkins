class jenkins_demo::profile::sensu::server {
  include ::jenkins_demo::profile::sensu::base
  include ::erlang

  # https://github.com/sensu/sensu-puppet/issues/392
  Class['::sensu::client::service'] ~> Class['::sensu::api::service']

  class { '::redis':
    syslog_facility => 'USER',
  }

  Class['::erlang'] ->
  class { '::rabbitmq':
    delete_guest_user => true,
  }

  rabbitmq_vhost { 'sensu':
    ensure => present,
  }
  rabbitmq_user { 'sensu':
    admin     => true,
    password  => hiera('sensu::rabbitmq_password', undef)
  }

  rabbitmq_user_permissions { 'sensu@sensu':
    configure_permission => '.*',
    read_permission      => '.*',
    write_permission     => '.*',
  }

  # if this is el7+, we want to manage the sensu user directly so we can add it
  # to the systemd-journal group.
  if $::osfamily == 'RedHat'
      and (versioncmp($::operatingsystemmajrelease, '6') > 0) {
    # manage the user account directly and *disable* the sensu classes
    # management.
    $manage_user = false
  } else {
    $manage_user = true
  }

  unless $manage_user {
    user { 'sensu':
      ensure  => 'present',
      system  => true,
      home    => '/opt/sensu',
      shell   => '/bin/false',
      comment => 'Sensu Monitoring Framework',
      groups  => ['systemd-journal'],
    }

    group { 'sensu':
      ensure => 'present',
      system => true,
    }
  }

  Class['::redis'] ->
  Class['::rabbitmq'] ->
  class { '::sensu':
    #    rabbitmq_user          => 'sensu',
    #rabbitmq_vhost              => 'sensu',
    #rabbitmq_password          => 'sensutest',
    #rabbitmq_reconnect_on_error => true,
    server                      => true,
    client                      => true,
    api                         => true,
    #api_user                    => 'sensu',
    #api_password                => 'sensutest',
    manage_user                 => $manage_user,
    client_custom               => {
      # username => 'sensu',
      password => 'sensutest',
      #vhost    => 'sensu',
    }
  }


  $hipchat = hiera('jenkins::plugins::hipchat', undef)

  if $hipchat {
    sensu::handler { 'hipchat':
      command  => '/opt/sensu/embedded/bin/handler-hipchat.rb',
      type     => 'pipe',
      config   => {
        apikey => $hipchat[token],
        room   => $hipchat[room],
        from   => 'Sensu',
      },
      default => true,
    }
  }

  #    $handlers_default ='
  #{
  #  "handlers": {
  #    "default": {
  #      "handlers": [
  #        "hipchat"
  #      ],
  #      "type": "set"
  #    }
  #  }
  #}
  #    '
  #  file { '/etc/sensu/conf.d/handlers_default.json':
  #  notify => [
  #    Class['sensu::server::service'],
  #    Class['sensu::api::service'],
  #  ]
  #}
  #  file { '/etc/sensu/conf.d/handlers_default.json':
  #  ensure  => file,
  #  owner   => 'sensu',
  #  group   => 'sensu',
  #  mode    => '0444',
  #} ->
  #sensu_handlers_default { 'foo':
  #  ensure => absent
  #}
  #sensu_handlers_default { 'hipchat':
  #  ensure => absent
  #}

  Class['sensu::api::service'] ->
  class { '::uchiwa':
    install_repo        => false,
    sensu_api_endpoints => [{
      name              => 'localhost',
      host              => '127.0.0.1',
      ssl               => false,
      port              => 4567,
      user              => 'sensu',
      pass              => 'sensutest',
      path              => '',
      timeout           => 5,
    }],
  }
}
