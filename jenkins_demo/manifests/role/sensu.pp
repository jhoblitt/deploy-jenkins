class jenkins_demo::role::sensu {
  include ::jenkins_demo::profile::base
  include ::jenkins_demo::profile::ganglia::gmond
  include ::jenkins_demo::profile::sensu::base
  include ::jenkins_demo::profile::sensu::server
  include ::jenkins_demo::profile::sensu::check::base
  include ::jenkins_demo::profile::sensu::check::sensu_server

  class { 'selinux': mode => 'enforcing' }
}
