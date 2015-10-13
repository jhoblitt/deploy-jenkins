class jenkins_demo::profile::docker::swarm {
  include ::consul

  # The consul module uses nanlui/staging < 2, which assumes the unzip binary
  # is in the default path
  ensure_packages(['unzip'])
  Package['unzip'] -> Class['consul']

  ::docker::run { 'swarm':
    image   => 'swarm',
    command => "join --addr=${::ipaddress_eth0}:2375 consul://${::ipaddress_eth0}:8500/swarm_nodes"
  }

  exec { 'consul join jenkins-master':
    path      => '/usr/local/bin/',
    require   => Class['consul'],
    before    => Docker::Run['swarm'],
    tries     => 10,
    try_sleep => 1,
  }
}
