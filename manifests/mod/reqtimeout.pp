#
# default
# RequestReadTimeout header=20-40,MinRate=500 body=20,MinRate=500
#
class apache::mod::reqtimeout (
                                $ensure            = 'installed',
                                $expires_active    = true,
                                $header_timeout    = '20',
                                $header_maxtimeout = '40',
                                $header_minrate    = '500',
                                $body_timeout      = '20',
                                $body_maxtimeout   = undef,
                                $body_minrate      = '500',
                              ) inherits apache::params {

  #LoadModule reqtimeout_module modules/mod_reqtimeout.so
  if($apache::params::reqtimeout_so==undef)
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
    apache::module { 'reqtimeout_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::reqtimeout_so}",
    }
  }

  #RequestReadTimeout [header=timeout[-maxtimeout][,MinRate=rate] [body=timeout[-maxtimeout][,MinRate=rate]

  file { "${apache::params::baseconf}/conf.d/reqtimeout.conf":
    ensure  => $ensure_conf_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Class[['apache', 'apache::version']], File["${apache::params::baseconf}/conf.d"] ],
    content => template("${module_name}/module/reqtimeout.erb"),
  }
}
