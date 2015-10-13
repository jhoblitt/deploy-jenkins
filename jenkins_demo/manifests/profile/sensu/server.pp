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

  $hipchat = hiera('sensu::plugins::hipchat', undef)

  if $hipchat {
    sensu::handler { 'hipchat':
      command  => '/opt/sensu/embedded/bin/handler-hipchat.rb',
      type     => 'pipe',
      config   => {
        apikey => $hipchat['apikey'],
        room   => $hipchat['room'],
        from   => $hipchat['from'],
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

  $access_log          = '/var/log/nginx/uchiwa.access.log'
  $error_log           = '/var/log/nginx/uchiwa.error.log'
  $private_dir         = '/var/private'
  $ssl_cert_path       = "${private_dir}/cert_chain.pem"
  $ssl_key_path        = "${private_dir}/private.key"
  $ssl_dhparam_path    = "${private_dir}/dhparam.pem"
  $ssl_root_chain_path = "${private_dir}/root_chain.pem"
  $ssl_cert            = hiera('ssl_cert', undef)
  $ssl_chain_cert      = hiera('ssl_chain_cert', undef)
  $ssl_root_cert       = hiera('ssl_root_cert', undef)
  $ssl_key             = hiera('ssl_key', undef)
  $add_header          = hiera('add_header', undef)
  $uchiwa_www_host     = hiera('uchiwa_www_host', 'jenkins-sensu')

  $proxy_set_header = [
    'Host            $host',
    'X-Real-IP       $remote_addr',
    'X-Forwarded-For $proxy_add_x_forwarded_for',
  ]

  if $ssl_cert and $ssl_key {
    $enable_ssl = true
  }

  selboolean { 'httpd_can_network_connect':
    value      => on,
    persistent => true,
  } ->
  Class['::nginx']

  selboolean { 'httpd_setrlimit':
    value      => on,
    persistent => true,
  } ->
  Class['::nginx']

  nginx::resource::upstream { 'uchiwa':
    ensure  => present,
    members => [
      'localhost:4180',
    ],
  }

  # If SSL is enabled and we are catching an DNS cname, we need to redirect to
  # the canonical https URL in one step.  If we do a http -> https redirect, as
  # is enabled by puppet-nginx's rewrite_to_https param, the the U-A will catch
  # a certificate error before getting to the redirect to the canonical name.
  $raw_prepend = [
    "if ( \$host != \'${uchiwa_www_host}\' ) {",
    "  return 301 https://${uchiwa_www_host}\$request_uri;",
    '}',
  ]

  if $enable_ssl {
    file { $private_dir:
      ensure   => directory,
      mode     => '0750',
      selrange => 's0',
      selrole  => 'object_r',
      seltype  => 'httpd_config_t',
      seluser  => 'system_u',
    }

    exec { 'openssl dhparam -out dhparam.pem 2048':
      path    => ['/usr/bin'],
      cwd     => $private_dir,
      umask   => '0433',
      creates => $ssl_dhparam_path,
    } ->
    file { $ssl_dhparam_path:
      ensure   => file,
      mode     => '0400',
      selrange => 's0',
      selrole  => 'object_r',
      seltype  => 'httpd_config_t',
      seluser  => 'system_u',
      replace  => false,
      backup   => false,
    }

    # note that nginx needs the signed cert and the CA chain in the same file
    concat { $ssl_cert_path:
      ensure   => present,
      mode     => '0444',
      selrange => 's0',
      selrole  => 'object_r',
      seltype  => 'httpd_config_t',
      seluser  => 'system_u',
      backup   => false,
      before   => Class['::nginx'],
    }
    concat::fragment { 'public - signed cert':
      target  => $ssl_cert_path,
      order   => 1,
      content => $ssl_cert,
    }
    concat::fragment { 'public - chain cert':
      target  => $ssl_cert_path,
      order   => 2,
      content => $ssl_chain_cert,
    }

    file { $ssl_key_path:
      ensure    => file,
      mode      => '0400',
      selrange  => 's0',
      selrole   => 'object_r',
      seltype   => 'httpd_config_t',
      seluser   => 'system_u',
      content   => $ssl_key,
      backup    => false,
      show_diff => false,
      before    => Class['::nginx'],
    }

    concat { $ssl_root_chain_path:
      ensure   => present,
      mode     => '0444',
      selrange => 's0',
      selrole  => 'object_r',
      seltype  => 'httpd_config_t',
      seluser  => 'system_u',
      backup   => false,
      before   => Class['::nginx'],
    }
    concat::fragment { 'root-chain - chain cert':
      target  => $ssl_root_chain_path,
      order   => 1,
      content => $ssl_chain_cert,
    }
    concat::fragment { 'root-chain - root cert':
      target  => $ssl_root_chain_path,
      order   => 2,
      content => $ssl_root_cert,
    }

    nginx::resource::vhost { 'uchiwa-ssl':
      ensure                => present,
      listen_port           => 443,
      ssl                   => true,
      rewrite_to_https      => false,
      access_log            => $access_log,
      error_log             => $error_log,
      ssl_key               => $ssl_key_path,
      ssl_cert              => $ssl_cert_path,
      ssl_dhparam           => $ssl_dhparam_path,
      ssl_session_timeout   => '1d',
      ssl_cache             => 'shared:SSL:50m',
      ssl_stapling          => true,
      ssl_stapling_verify   => true,
      ssl_trusted_cert      => $ssl_root_chain_path,
      resolver              => [ '8.8.8.8', '4.4.4.4'],
      proxy                 => 'http://uchiwa',
      proxy_redirect        => 'default',
      proxy_connect_timeout => '150',
      proxy_set_header      => $proxy_set_header,
      add_header            => $add_header,
      raw_prepend           => $raw_prepend,
    }
  }

  nginx::resource::vhost { 'uchiwa':
    ensure                => present,
    listen_port           => 80,
    ssl                   => false,
    access_log            => $access_log,
    error_log             => $error_log,
    proxy                 => 'http://uchiwa',
    proxy_redirect        => 'default',
    proxy_connect_timeout => '150',
    proxy_set_header      => $proxy_set_header,
    rewrite_to_https      => $enable_ssl ? {
      true    => true,
      default => false,
    },
    # see comment above $raw_prepend declaration
    raw_prepend           => $enable_ssl ? {
      true     => $raw_prepend,
      default  => undef,
    },
  }

  Class['::uchiwa'] ->
  class { '::oauth2_proxy':
    config => {
      http_address      => '127.0.0.1:4180',
      client_id         => '4718acded1e04f5647b8',
      client_secret     => '4bc493b71217ca26f9e2e0cc33544b1aba86b258',
      github_org        => 'lsst',
      upstreams         => [ 'http://127.0.0.1:3000' ],
      cookie_secret     => '1234',
      pass_access_token => false,
      pass_host_header  => true,
      provider          => 'github',
      redirect_url      => 'https://uchiwatest.lsst.codes/oauth2/callback',
      email_domains     => [ '*' ],
    }
  }

}
