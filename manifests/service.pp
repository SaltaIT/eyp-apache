class apache::service (
                        $ensure                    = 'running',
                        $manage_service            = true,
                        $manage_docker_service     = true,
                        $enable                    = true,
                        $systemd_socket_activation = false,
                      ) inherits apache::params {

  #
  validate_bool($manage_docker_service)
  validate_bool($manage_service)
  validate_bool($enable)

  validate_re($ensure, [ '^running$', '^stopped$' ], "Not a valid daemon status: ${ensure}")

  $is_docker_container_var=getvar('::eyp_docker_iscontainer')
  $is_docker_container=str2bool($is_docker_container_var)

  if( $is_docker_container==false or
      $manage_docker_service)
  {
    if($manage_service)
    {
      if($systemd_socket_activation)
      {
        if($apache::params::modsystemd)
        {
          # socket activation
          fail('TODO: currently unimplemented')
        }
        else
        {
          fail('mod_systemd not loaded, socket activation unsupported')
        }
      }
      else
      {
        service { $apache::params::servicename:
          ensure  => $ensure,
          name    => $apache::params::servicename,
          enable  => $enable,
          require => File["${apache::params::baseconf}/${apache::params::conffile}"],
        }
      }
    }
  }
}
