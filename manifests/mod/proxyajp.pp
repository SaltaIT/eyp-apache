class apache::mod::proxyajp (
                              $ensure = 'installed'
                            ) inherits apache::params {

  if($apache::params::modproxyajp_so==undef)
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
    apache::module { 'proxy_ajp_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modproxyajp_so}",
    }
  }
}
