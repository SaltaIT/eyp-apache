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
          # http://unix.stackexchange.com/questions/118172/how-to-start-to-use-httpd-with-socket-activation-systemd
          fail('TODO: currently unimplemented')
        }
        else
        {
          fail('mod_systemd not loaded, socket activation unsupported')
        }
      }
      else
      {
        exec { 'apachectl':
          command     => "${apache::params::apachectl} -t",
          refreshonly => true,
          before      => Service[$apache::params::servicename],
        }

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
