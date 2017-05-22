class apache::mod::proxy(
                          $ensure              = 'installed',
                          $proxystatus         = true,
                          $proxytimeout        = undef,
                          $proxy_requests      = false,
                          $proxy_via           = false,
                          $proxy_preserve_host = false,
                        ) inherits apache::params {

  if($apache::params::modproxy_so==undef)
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
    apache::module { 'proxy_module':
      sofile => "${apache::params::modulesdir}/${apache::params::modproxy_so}",
      order  => '00',
    }
  }

  file { "${apache::params::baseconf}/conf.d/mod_proxy.conf":
    ensure  => $ensure_conf_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File["${apache::params::baseconf}/conf.d"],
    content => template("${module_name}/proxy/modproxy.erb"),
  }
}
