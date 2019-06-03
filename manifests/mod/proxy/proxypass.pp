# puppet2sitepp @apacheproxypasses
define apache::mod::proxy::proxypass(
                                      $url,
                                      $destination,
                                      $servername        = $name,
                                      $vhost_order       = '00',
                                      $port              = '80',
                                      $connectiontimeout = undef,
                                      $disablereuse      = undef,
                                      $timeout           = undef,
                                      $location          = undef,
                                    ) {
  #
  concat::fragment { "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run proxypass ${url} ${destination}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/proxy/proxypass.erb"),
    order   => '19',
  }
}
