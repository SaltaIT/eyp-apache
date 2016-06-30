class apache::mod::deflate(
                            $ensure = 'installed'
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
    apache::module { 'deflate_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::deflate_so}",
    }
  }

  file { "${apache::params::baseconf}/conf.d/deflate.conf":
    ensure  => $ensure_conf_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Class[['apache', 'apache::version']], File["${apache::params::baseconf}/conf.d"] ],
    content => template("${module_name}/module/deflate.erb"),
  }

}
