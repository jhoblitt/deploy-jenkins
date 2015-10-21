forge 'https://forgeapi.puppetlabs.com'

mod 'puppetlabs/stdlib'
mod 'camptocamp/augeas'
mod 'stahnma/epel'
mod 'jhoblitt/sysstat'

mod 'maestrodev/wget', '~> 1.7.0'
mod 'puppetlabs/firewall', '~> 1.5.0'
mod 'jfryman/nginx', '~> 0.2.7'
mod 'jfryman/selinux', '~> 0.2.3'
mod 'saz/timezone', '~> 3.3.0'
mod 'puppetlabs/ntp', '~> 3.3.0'
mod 'juniorsysadmin/irqbalance', '~> 1.0.4'
mod 'thias/tuned', '~> 1.0.2'

mod 'aco/yum_autoupdate',
  :git => 'https://github.com/jhoblitt/aco-yum_autoupdate.git',
  :ref => 'bugfix/operatingsystemmajrelease-is-a-string'

mod 'saz/sudo',
  :git => 'https://github.com/pbyrne413/puppet-sudo',
  :ref => '30feebf655c4966b96ae328c40c1a2dc144c2e66'
mod 'rtyler/jenkins',
  :path => './puppet-jenkins'
#  :git => 'https://github.com/jenkinsci/puppet-jenkins.git',
#  :ref => 'df3c6dfd7c49143966541ac2be79f5bb608b8247'
mod 'lsst/lsststack',
  :git => 'https://github.com/lsst-sqre/puppet-lsststack.git',
  :ref => '4b376b0bfae70c4c0aef15e3f3c837395722a139'

mod 'jhoblitt/ganglia', '~> 2.0'
mod 'mayflower/php', '~> 3.2'
# https://github.com/puppetlabs/puppetlabs-concat/pull/361
mod 'puppetlabs/concat',
  :git => 'https://github.com/puppetlabs/puppetlabs-concat.git',
  :ref => 'fd4f1e2d46a86f1659da420f4ce042882d38e021'

mod 'stankevich/python', '~> 1.9'

mod 'arioch/redis',
  :git => 'https://github.com/arioch/puppet-redis.git',
  :ref => 'ef0fadfe99cc88a508a0fe8054975fa3d9f8745f'
mod 'garethr/erlang', '~> 0.3'
mod 'puppetlabs/rabbitmq', '~> 5.2'
mod 'sensu/sensu',
  :path => '/home/jhoblitt/github/sensu-puppet'
  #:git => 'https://github.com/jhoblitt/sensu-puppet.git',
  #:ref => '91c5b0abc8355dc8874275463663544e3dc5b7bc'

mod 'puppetlabs/gcc', '~> 0.3'
mod 'yelp-uchiwa', '~> 0.3'

mod 'lsst/jenkins_demo', :path => './jenkins_demo'

# install ruby-devel & bundler for debugging inside VMs
mod 'puppetlabs/ruby'
