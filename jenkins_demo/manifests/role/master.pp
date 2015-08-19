class jenkins_demo::role::master {
  include ::jenkins_demo::profile::base
  include ::jenkins_demo::profile::ganglia::gmond
  include ::jenkins_demo::profile::ganglia::web
  include ::jenkins_demo::profile::master
  include ::jenkins_demo::profile::sensu::base

  sensu::subscription { 'base': }
  sensu::subscription { 'jenkins-master': }
  sensu::subscription { 'jenkins-slave': }

  class { 'selinux': mode => 'enforcing' }
}
