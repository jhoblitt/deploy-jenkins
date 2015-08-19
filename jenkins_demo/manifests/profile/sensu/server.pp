class jenkins_demo::profile::sensu::server {
  include ::jenkins_demo::profile::sensu::base
  include ::nginx
  include ::erlang

  # https://github.com/sensu/sensu-puppet/issues/392
  Class['::sensu::client::service'] ~> Class['::sensu::api::service']

  class { '::redis':
    syslog_facility => 'USER',
  }

  selboolean { 'nis_enabled':
    value      => on,
    persistent => true,
  } ->
  Class['::rabbitmq']

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

  Class['::redis'] ->
  Class['::rabbitmq'] ->
  Class['::sensu']

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

  Class['::sensu'] ->
  class { '::uchiwa':
    install_repo        => false,
    host                => '127.0.0.1',
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
