# puppet2sitepp @apachereverseproxypasses
define apache::mod::proxy::vhostsettings(
                                          $servername          = $name,
                                          $vhost_order         = '00',
                                          $port                = '80',
                                          $proxy_requests      = false,
                                          $proxy_via           = false,
                                          $proxy_preserve_host = false,
                                        ) {
  #
  concat::fragment { "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run proxy vhost settings ${url} ${destination}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/proxy/proxyvhostsettings.erb"),
    order   => '19',
  }
}
