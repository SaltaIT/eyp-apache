# puppet2sitepp @apachelocations
define apache::location (
                              $servername         = $name,
                              $vhost_order        = '00',
                              $port               = '80',
                              $location           = '/',
                              $allowedip          = [],
                              $denyip             = [],
                              $block              = false,
                              $options            = [],
                              $ssl_require        = undef,
                              $allowoverride      = undef,
                              $limit_http_methods = [],
                            ) {

  if($allowedip!=undef)
  {
    validate_array($allowedip)
  }

  if($denyip!=undef)
  {
    validate_array($denyip)
  }

  validate_string($vhost_order)

  validate_string($port)

  validate_string($name)

  validate_array($options)

  validate_string($allowoverride)

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run ${location}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/vhost/location.erb"),
    order   => '03',
  }
}
