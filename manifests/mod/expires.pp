#LoadModule expires_module <%= scope.lookupvar('apache::params::modulesdir') %>/mod_expires.so

class apache::mod::deflate ($ensure='installed') inherits apache::params {

  if($apache::params::deflate_so==undef)
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
    apache::module { 'expires_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modexpires_so}",
    }
  }
}
