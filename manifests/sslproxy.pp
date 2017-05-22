define apache::sslproxy (
                          $ssl_proxy_enabled           = true,
                          $ssl_proxy_verify            = 'none',
                          $ssl_proxy_check_peer_cn     = false,
                          $ssl_proxy_check_peer_name   = false,
                          $ssl_proxy_check_peer_expire = false,
                          $vhost_order                 = '00',
                          $port                        = '80',
                          $servername                  = $name,
                          $description                 = undef,
                        ) {
  #
  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run ssl proxy":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/proxy/sslproxy.erb"),
    order   => '19',
  }
}
