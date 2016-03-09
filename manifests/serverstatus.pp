define apache::serverstatus (
                              $order            = '00',
                              $port             = '80',
                              $serverstatus_url = '/server-status',
                              $servername       = $name,
                              $allowedip        = hiera('eypapache::monitips', undef),
                              $defaultvh        = false,
                            ) {

  if($allowedip!=undef)
  {
    validate_array($allowedip)
  }

  if($defaultvh)
  {
    concat::fragment{ "${apache::params::baseconf}/conf.d/00_default.conf serverstatus":
      target  => "${apache::params::baseconf}/conf.d/00_default.conf",
      content => template("${module_name}/serverstatus/serverstatus.erb"),
      order   => '08',
    }
  }
  else
  {
    concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf serverstatus":
      target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
      content => template("${module_name}/serverstatus/serverstatus.erb"),
      order   => '08',
    }
  }

}
