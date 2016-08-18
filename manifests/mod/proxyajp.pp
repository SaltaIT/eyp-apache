class apache::mod::proxyajp (
                              $ensure = 'installed'
                            ) inherits apache::params {

  if($apache::params::modproxyajp_so==undef)
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
    apache::module { 'proxy_ajp_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modproxyajp_so}",
      require => Class['apache::mod::proxy'],
    }
  }
}
