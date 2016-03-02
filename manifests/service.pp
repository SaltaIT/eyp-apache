class apache::service (
                        $manage_service=true,
                        $manage_docker_service=false,
                      ) inherits apache::params {

  if($::eyp_docker_iscontainer==undef or
      $::eyp_docker_iscontainer =~ /false/ or
      $manage_docker_service)
  {
    if($manage_service)
    {
      service { $apache::params::servicename:
        ensure  => 'running',
        name    => $apache::params::servicename,
        enable  => true,
        require => File["${apache::params::baseconf}/${apache::params::conffile}"],
      }
    }
  }
}
