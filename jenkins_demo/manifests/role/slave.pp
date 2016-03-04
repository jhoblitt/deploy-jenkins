class jenkins_demo::role::slave {
  include ::jenkins_demo::profile::base
  include ::jenkins_demo::profile::ganglia::gmond
  include ::jenkins_demo::profile::slave
  include ::jenkins_demo::profile::docker::base
  include ::jenkins_demo::profile::docker::swarm
  class { 'selinux': mode => 'disabled' }

  if $::operatingsystemmajrelease == '6' {
    file_line { 'enable devtoolset-3':
      line    => '. /opt/rh/devtoolset-3/enable',
      path    => '/home/build0/.bashrc',
      require => User['build0'],
    }
  }
}
