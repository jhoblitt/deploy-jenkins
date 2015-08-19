class jenkins_demo::role::sensu {
  include ::jenkins_demo::profile::base
  include ::jenkins_demo::profile::ganglia::gmond
  include ::jenkins_demo::profile::sensu::base
  include ::jenkins_demo::profile::sensu::server
  include ::jenkins_demo::profile::sensu::check::base
  include ::jenkins_demo::profile::sensu::check::sensu_server
  include ::jenkins_demo::profile::sensu::check::jenkins_master
  include ::jenkins_demo::profile::sensu::check::jenkins_slave

  sensu::subscription { 'base': }
  sensu::subscription { 'sensu-server': }

  # XXX issues between rabbitmq and the selinux policy are suspected
  class { 'selinux': mode => 'permissive' }
}
