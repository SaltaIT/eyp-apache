class apache::mod::proxywstunnel(
                                  $ensure = 'installed'
                                ) inherits apache::params {

  if($apache::params::modproxywstunnel_so==undef)
  {
    fail('Unsupported')
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
    include ::apache::mod::proxy

    apache::module { 'proxy_wstunnel_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modproxywstunnel_so}",
      require => Class['apache::mod::proxy'],
    }
  }
}
