class apache::mod::proxybalancer ($ensure='installed') inherits apache::params {

  if($apache::params::modproxybalancer_so==undef)
  {
    fail('Unsupported')
  }

  if ! defined(Class['apache::mod::proxy'])
  {
    fail('You must include the apache::mod::proxy class before using any mod::proxy classes')
  }

  if($ensure=='installed')
  {
    $ensure_conf_file='present'
  }
  elsif($ensure=='purged')
  {
    $ensure_conf_file='absent'
  }
  else
  {
    fail("unsupported ensure: ${ensure}")
  }

  if($ensure=='installed')
  {
    apache::module { 'proxy_balancer_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modproxybalancer_so}",
    }

    #TODO: testing
    if (versioncmp($apache::version, '2.4') >= 0 )
    {
      # For Apache 2.4 and above add mod_lbmethod_byrequests and mod_slotmem_shm to the list.
      # LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
      # LoadModule slotmem_shm_module modules/mod_slotmem_shm.so

      apache::module { 'lbmethod_byrequests_module':
        sofile  => "${apache::params::modulesdir}/mod_lbmethod_byrequests.so",
      }

      # apache::module { 'slotmem_shm_module':
      #   sofile  => "${apache::params::modulesdir}/mod_slotmem_shm.so",
      # }
    }

  }
}
