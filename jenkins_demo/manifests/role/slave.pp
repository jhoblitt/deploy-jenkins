class jenkins_demo::role::slave {
  include ::jenkins_demo::profile::base
  include ::jenkins_demo::profile::ganglia::gmond
  include ::jenkins_demo::profile::slave
  include ::jenkins_demo::profile::sensu::base
  include ::jenkins_demo::profile::sensu::client
  include ::jenkins_demo::profile::sensu::check::base
  include ::jenkins_demo::profile::sensu::check::jenkins_slave
  class { 'selinux': mode => 'disabled' }

  if $::operatingsystemmajrelease == '6' {
    include ::jenkins_demo::profile::devtoolset_3

    Class['::jenkins_demo::profile::devtoolset_3'] ->
      Class['::jenkins_demo::profile::slave']

    file_line { 'enable devtoolset-3':
      line    => '. /opt/rh/devtoolset-3/enable',
      path    => '/home/build0/.bashrc',
      require => User['build0'],
    }
  }
}
