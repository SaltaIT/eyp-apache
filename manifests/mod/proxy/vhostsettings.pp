# puppet2sitepp @apachereverseproxypasses
define apache::mod::proxy::vhostsettings(
                                          $servername          = $name,
                                          $vhost_order         = '00',
                                          $port                = '80',
                                          $proxy_requests      = undef,
                                          $proxy_via           = undef,
                                          $proxy_preserve_host = undef,
                                        ) {
  #
  concat::fragment { "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run proxy vhost settings - must be unique -":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/proxy/proxyvhostsettings.erb"),
    order   => '19',
  }
}
