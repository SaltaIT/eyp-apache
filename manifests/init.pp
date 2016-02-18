# == Class: apache
#
class apache (
    $mpm=$apache::params::mpm_default,
    $servertokens=$apache::params::servertokens_default,
    $timeout=$apache::params::timeout_default,
    $keepalive=$apache::params::keepalive_default,
    $keepalivetimeout=$apache::params::keepalivetimeout_default,
    $maxkeepalivereq=$apache::params::maxkeepalivereq_default,
    $extendedstatus=$apache::params::extendedstatus_default,
    $serversignature=$apache::params::serversignature_default,
    $listen=[ '80' ],
    $namevirtualhosts=undef,
    $ssl=false,
    $sni=true,
    $trace=false,
    $version=$apache::version::default,
    $apache_username=$apache::params::apache_username,
    $apache_group=$apache::params::apache_group,
    $server_admin=$apache::params::server_admin_default,
    $directoty_index=['index.html'],
    $maxclients=$apache::params::maxclients_default,
    $maxrequestsperchild=$apache::params::maxrequestsperchild_default,
  )inherits apache::params {

  if($version!=$apache::version::default)
  {
    fail("unsupported version for this system - expected: ${version} supported: ${apache::version::default}")
  }

  validate_array($listen)

  if($namevirtualhosts)
  {
    validate_array($namevirtualhosts)
  }

  package { $apache::params::packagename:
    ensure => 'installed',
    notify => Service[$apache::params::servicename],
  }

  if($apache::params::packagenamedevel!=undef)
  {
    package { $apache::params::packagenamedevel:
      ensure => 'installed',
    }
  }

  if($apache::params::sysconfigfile!=undef and $apache::params::sysconfigtemplate!=undef)
  {
    file { $apache::params::sysconfigfile:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template($apache::params::sysconfigtemplate),
    }
  }


  file { "${apache::params::baseconf}/conf.d":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package[$apache::params::packagename],
  }

  file { "${apache::params::baseconf}/conf.d/sites":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => File["${apache::params::baseconf}/conf.d"],
  }

  file { "${apache::params::baseconf}/${apache::params::conffile}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("apache/${apache::params::conftemplate}"),
    require => File["${apache::params::baseconf}/conf.d/sites"],
    notify  => Service[$apache::params::servicename],
  }

  concat { "${apache::params::baseconf}/conf.d/modules.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$apache::params::packagename],
    notify  => Service[$apache::params::servicename],
  }

  concat::fragment { "loadmodule header ${apache::params::baseconf}":
    target  => "${apache::params::baseconf}/conf.d/modules.conf",
    order   => '00', #answer to life the universe and everything
    content => "#puppet managed file\n",
  }

  if($ssl)
  {
    package { $apache::params::modssl_package:
      ensure => 'installed',
    }

    file { "${apache::params::baseconf}/ssl":
      ensure  => 'directory',
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package[$apache::params::packagename],
    }

    file { "${apache::params::baseconf}/conf.d/ssl.conf":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require =>  [
                    File["${apache::params::baseconf}/conf.d"],
                    Package[[$apache::params::packagename, $apache::params::modssl_package]]
                  ],
      notify  => Service[$apache::params::servicename],
      content => template("${module_name}/ssl/ssl.erb"),
    }
  }

  service { $apache::params::servicename:
    ensure  => 'running',
    name    => $apache::params::servicename,
    enable  => true,
    require => File["${apache::params::baseconf}/${apache::params::conffile}"],
  }

}
