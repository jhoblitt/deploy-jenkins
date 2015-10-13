class jenkins_demo::profile::docker::base {
  include ::docker

  Firewallchain {
    purge  => true,
    ignore => [
      '172.17',
      'docker',
      'DOCKER',
    ],
    require => Class['docker'],
  }

  firewallchain { 'DOCKER:filter:IPv4':
    ensure => 'present',
  }
  firewallchain { 'DOCKER:nat:IPv4':
    ensure => 'present',
  }
  firewallchain { 'FORWARD:filter:IPv4':
    ensure => 'present',
    policy => 'accept',
  }
  firewallchain { 'INPUT:filter:IPv4':
    ensure => 'present',
    policy => 'accept',
  }
  firewallchain { 'INPUT:nat:IPv4':
    ensure => 'present',
    policy => 'accept',
  }
  firewallchain { 'OUTPUT:filter:IPv4':
    ensure => 'present',
    policy => 'accept',
  }
  firewallchain { 'OUTPUT:nat:IPv4':
    ensure => 'present',
    policy => 'accept',
  }
  firewallchain { 'POSTROUTING:nat:IPv4':
    ensure => 'present',
    policy => 'accept',
  }
  firewallchain { 'PREROUTING:nat:IPv4':
    ensure => 'present',
    policy => 'accept',
  }
}
