class jenkins_demo::profile::sensu::check::base {
  #
  # base checks
  #
  sensu::check { 'diskspace':
    command     => '/opt/sensu/embedded/bin/check-disk-usage.rb -w 80 -c 90 -W 80 -K 90',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'memory-percent':
    command     => '/opt/sensu/embedded/bin/check-memory-percent.rb -w 75 -c 90',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  # requires ntpq
  sensu::check { 'ntp':
    command     => '/opt/sensu/embedded/bin/check-ntp.rb -w 25 -c 50',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'ntp-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service ntpd status\'',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'ssh':
    command     => '/opt/sensu/embedded/bin/check-banner.rb -p 22',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'ssh-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service sshd status\'',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'yum-cron-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service yum-cron status\'',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  if $::osfamily == 'RedHat'
     and (versioncmp($::operatingsystemmajrelease, '6') > 0) {
    # sensu user must be in the systemd-journal group to use journalctl on el7
    sensu::check { 'yum-cron has run':
      command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'journalctl --since=-24hours SYSLOG_IDENTIFIER="run-parts(/etc/cron.daily)" MESSAGE="finished 0yum-daily.cron"\'',
      interval    => 3600,
      refresh     => 15,
      subscribers => 'base',
      standalone  => false,
    }
  }

  sensu::check { 'sensu-client-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service sensu-client status\'',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'irqbalance-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service irqbalance status\'',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'crond-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service crond status\'',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'tuned-service':
    command     => '/opt/sensu/embedded/bin/check-cmd.rb -c \'service tuned status\'',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }

  sensu::check { 'zombies':
    command     => '/opt/sensu/embedded/bin/check-process.rb -s Z -w 5 -c 5 -W0 -C0',
    refresh     => 15,
    subscribers => 'base',
    standalone  => false,
  }
}
