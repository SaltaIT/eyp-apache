class apache::mod::php(
                        $ensure = 'installed'
                      ) inherits apache::params {

  include ::apache

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
      ensure  => $ensure,
      require => Package[$apache::params::packagename],
    }

    if($ensure=='installed')
    {
      Package[$apache::params::modphp_pkg] {
        before => [ File["${apache::params::baseconf}/${apache::params::conffile}"], Apache::Module[$apache::params::modphp_modulename] ],
      }
    }
  }
  else
  {
    include ::php
  }


  if($ensure=='installed')
  {
    apache::module { $apache::params::modphp_modulename:
      sofile  => "${apache::params::modulesdir}/${apache::params::modphp_so}",
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
