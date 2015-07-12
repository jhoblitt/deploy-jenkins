class jenkins_demo::profile::ganglia::web {
  include ::php
  include ::nginx

  # XXX this is to work around jfryman/nginx adding 300 to the priority of the
  # concat fragments used to construct the ssl vhost template.  The default
  # priority of 500 works with a non-ssl vhost but ends up the before the
  # server {} block of an ssl host.  Inversly, a priority of 800-899 ends up
  # after the server {} block of a non-ssl host.
  if hiera('ssl_cert', undef) and hiera('ssl_key', undef) {
    $priority = 850
  } else {
    $priority = 550
  }

  nginx::resource::location { '/ganglia':
    ensure              => present,
    priority            => $priority,
    vhost               => 'jenkins',
    location_custom_cfg => {
      alias             => '/usr/share/ganglia',
      rewrite           => '^(/ganglia)(/.*?\.php)(/.*)?$ /...$document_root/...$1/...$2/...$3 last',
      access_log        => '/var/log/nginx/ganglia.access.log',
      error_log         => '/var/log/nginx/ganglia.error.log',
    }
  }

  # generic nginx php support via php-fpm (fastcgi) for internal requests
  #
  # from:
  # http://yalis.fr/cms/index.php/post/2013/10/26/Configure-PHP-with-Nginx-only-once-for-several-aliases
  #
  nginx::resource::location { '/...':
    ensure              => present,
    priority            => $priority,
    vhost               => 'jenkins',
    internal            => true,
    autoindex           => 'off',
    location_custom_cfg => {
      access_log        => '/var/log/nginx/ganglia.access.log',
      error_log         => '/var/log/nginx/ganglia.error.log',
    },
    raw_append => [
      'location ~ ^/\.\.\.(?<p_doc_root>.*)/\.\.\.(?<p_prefix>.*)/\.\.\.(?<p_script>.*\.php)/\.\.\.(?<p_pathinfo>.*)$ {',
      '  fastcgi_pass  127.0.0.1:9000;',
      '  fastcgi_index index.php;',
      '  include fastcgi_params;',
      '  fastcgi_param SCRIPT_FILENAME $p_doc_root$p_script;',
      '  fastcgi_param SCRIPT_NAME     $p_prefix$p_script;',
      '  fastcgi_param REQUEST_URI     $p_prefix$p_script$p_pathinfo$is_args$query_string;',
      '  fastcgi_param DOCUMENT_URI    $p_prefix$p_script$p_pathinfo;',
      '  fastcgi_param DOCUMENT_ROOT   $p_doc_root;',
      '  fastcgi_param PATH_INFO       $p_pathinfo if_not_empty;',
      '}',
    ],
  }

  $clusters = [
    {
      name    => 'jenkins',
      address => [
        'jenkins-master',
      ],
    },
  ]

  class { '::ganglia::gmetad':
    clusters => $clusters,
    gridname => 'lsst.codes',
  }

  class { '::ganglia::web': }

}