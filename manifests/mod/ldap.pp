class apache::mod::ldap (
                          $ensure                  = 'installed',
                          $ldap_verify_server_cert = false,
                        ) inherits apache::params {

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

  file { "${apache::params::baseconf}/conf.d/mod_ldap.conf":
    ensure  => $ensure_conf_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File["${apache::params::baseconf}/conf.d"],
    content => template("${module_name}/module/ldap.erb"),
  }

}
