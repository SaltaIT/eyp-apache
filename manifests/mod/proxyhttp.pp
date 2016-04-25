class apache::mod::proxyhttp ($ensure='installed') inherits apache::params {

  if($apache::params::modproxyhttp_so==undef)
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
    apache::module { 'proxy_http_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modproxyhttp_so}",
    }
  }
}
