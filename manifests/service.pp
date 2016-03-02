class apache::service($manage_service=true,) inherits apache::params {

  if($::eyp_docker_iscontainer==undef or $::eyp_docker_iscontainer =~ /false/)
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
