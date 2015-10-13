class jenkins_demo::profile::docker::swarm_manager {
  # The consul module uses nanlui/staging < 2, which assumes the unzip binary
  # is in the default path
  ensure_packages(['unzip'])
  Package['unzip'] -> Class['consul']

  class { '::consul':
    config_hash   => {
      server      => true,
      data_dir    => '/opt/consul',
      client_addr => '0.0.0.0',
      #bind_addr  => "%{::ipaddress_eth1}",
      bootstrap   => true,
    }
  }

  ::docker::run { 'swarm-manager':
    image   => 'swarm',
    ports   => '3000:2375',
    command => "manage consul://${::ipaddress_eth0}:8500/swarm_nodes",
    #require => Docker::Run['swarm'],
  }
}
