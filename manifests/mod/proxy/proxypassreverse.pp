# puppet2sitepp @apachereverseproxypasses
define apache::mod::proxy::proxypassreverse (
                                              $servername,
                                              $destination,
                                              $vhost_order = '00',
                                              $port        = '80',
                                              $url         = $name,
                                              $location    = undef,
                                            ) {
  #
  concat::fragment { "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run proxypassreverse ${url} ${destination}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/proxy/proxypassreverse.erb"),
    order   => '19',
  }
}
