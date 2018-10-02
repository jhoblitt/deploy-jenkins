class jenkins_demo::profile::jenkins::agent(
  Enum['normal', 'exclusive'] $slave_mode          = 'normal',
  Optional[Variant[Array[String], String]] $labels = undef,
  Boolean                      $use_default_labels = true,
  Integer                               $executors = 1,
  String                                $masterurl = 'http://jenkins-master:8080',
) {
  if $::operatingsystemmajrelease == '7' {
    include ::docker

    $docker = 'docker'
    $dockergc = '/usr/local/bin/docker-gc'

    archive { 'docker-gc':
      source  => 'https://raw.githubusercontent.com/spotify/docker-gc/master/docker-gc',
      path    => $dockergc,
      cleanup => false,
      extract => false,
    }
    # this isn't nessicary with puppet/archive 1.x
    -> file { $dockergc:
      mode => '0555',
    }

    cron { 'docker-gc':
      command => $dockergc,
      minute  => '0',
      hour    => '4',
    }
  } else {
    $docker = undef
  }

  # XXX migrate to hiera?
  $default_labels = [
    $::hostname,
    downcase($::os['name']),
    downcase("${::os['name']}-${::os['release']['major']}"),
    $docker,
  ]

  # XXX migrate to hiera?
  if ($use_default_labels) {
    $real_labels = concat($default_labels, $labels)
  } else {
    $real_labels = $labels
  }

  # provides killall on el6 & el7
  ensure_packages(['psmisc'])
  ensure_packages(['lsof'])
  # unzip is needed by packer-layercake
  ensure_packages(['unzip'])

  $user  = 'jenkins-swarm'
  $magic = 444

  group { $user:
    ensure => present,
    gid    => $magic,
  }

  user { $user:
    ensure     => present,
    comment    => 'Jenkins Swarm Client user',
    home       => '/j',
    managehome => true,
    system     => true,
    uid        => $magic,
    groups     => ['jenkins-swarm'],
  }
}
