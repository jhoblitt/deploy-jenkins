class jenkins_demo::profile::sensu::base {
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

  class { '::sensu':
    #server                      => true,
    #client                      => true,
    #api                         => true,
    manage_user                 => $manage_user,
    client_custom               => {
      # username => 'sensu',
      password => 'sensutest',
      #vhost    => 'sensu',
    }
  }

  # we're being lazy and installing the same set of plugins on all nodes

  # the selinux plugin is not yet released a a gem
  #'sensu-plugins-selinux',
  $plugins = [
    'sensu-plugins-disk-checks',
    'sensu-plugins-hipchat',
    'sensu-plugins-memory-checks',
    'sensu-plugins-http',
    'sensu-plugins-jenkins',
    'sensu-plugins-rabbitmq',
    'sensu-plugins-network-checks',
    'sensu-plugins-ntp',
    'sensu-plugins-redis',
    'sensu-plugins-process-checks',
    'sensu-plugins-ssl',
  ]

  # sensu must be installed before the sensu_gem provider is functional
  #
  # we also want all of the plugins to be install before any of the sensu
  # services are started so we don't get runtime or check failures
  package { $plugins:
    ensure   => 'installed',
    provider => 'sensu_gem',
    require  => [
      Class['::sensu::package'],
    ],
    before   => [
      Class['::sensu::client::service'],
      Class['::sensu::server::service'],
      Class['::sensu::api::service'],
    ],
  }

  ensure_packages('bc')
  Package['bc'] -> Package['sensu-plugins-memory-checks']

  $jenkins_pkgs = ['libxml2', 'patch', 'zlib-devel']
  ensure_packages($jenkins_pkgs)
  include ::gcc
  Package[$jenkins_pkgs] -> Package['sensu-plugins-jenkins']
  Class['::gcc'] -> Package['sensu-plugins-jenkins']
}
