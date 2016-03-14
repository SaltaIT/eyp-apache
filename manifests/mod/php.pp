class apache::mod::php ($ensure='installed') inherits apache::params {

  if($apache::params::modphp_so==undef)
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

  if($apache::params::modphp_pkg!=undef)
  {
    package { $apache::params::modphp_pkg:
      ensure => $ensure,
    }
  }
  else
  {
    include ::php
  }


  if($ensure=='installed')
  {
    apache::module { 'php5_module':
      sofile  => "${apache::params::modulesdir}/${apache::params::modphp_so}",
      require => Package[$apache::params::modphp_pkg],
    }
  }

  file { "${apache::params::baseconf}/conf.d/php.conf":
    ensure  => $ensure_conf_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Class[['apache', 'apache::version']], File["${apache::params::baseconf}/conf.d"] ],
    content => template("${module_name}/module/php.erb"),
  }

}
