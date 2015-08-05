class jenkins_demo::profile::sensu::client {
  include ::jenkins_demo::profile::sensu::base

#  Class['jenkins_demo::profile::sensu::base'] ->
  class { 'sensu':
    #   rabbitmq_password  => 'sensutest',
    # rabbitmq_host      => 'jenkins-master',
  }
}
