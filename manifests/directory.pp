define apache::directory (
                              $servername,
                              $vhost_order      = '00',
                              $port             = '80',
                              $directory        = $name,
                              $allowedip        = undef,
                              $denyip           = undef,
                              $options          = $apache::params::options_default,
                              $allowoverride    = $apache::params::allowoverride_default,
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

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf ${directory}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf",
    content => template("${module_name}/directory/directory.erb"),
    order   => '03',
    }
}
