class apache::mod::headers(
                            $ensure = 'installed'
                          ) inherits apache::params {

  if($apache::params::headers_so==undef)
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
    apache::module { 'headers_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::headers_so}",
    }
  }

}
