#LoadModule expires_module <%= scope.lookupvar('apache::params::modulesdir') %>/mod_expires.so

class apache::mod::deflate(
                            $ensure         = 'installed',
                            $default_expire = 'access plus 1 year'
                          ) inherits apache::params {

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

  file { "${apache::params::baseconf}/conf.d/expires.conf":
    ensure  => $ensure_conf_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Class[['apache', 'apache::version']], File["${apache::params::baseconf}/conf.d"] ],
    content => template("${module_name}/module/expires.erb"),
  }
}
