define apache::serverstatus (
                              $order            = '00',
                              $port             = '80',
                              $serverstatus_url = '/server_status',
                              $servername       = $name,
                              $allowedip        = undef,
                            ) {

  if($allowedip!=undef)
  {
    validate_array($allowedip)
  }

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf serverstatus":
    target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
    content => template("${module_name}/serverstatus/serverstatus.erb"),
    order   => '10',
  }
}
