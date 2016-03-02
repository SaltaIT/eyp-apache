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
    $customlog_type=$apache::params::customlog_type_default,
    $logformats=undef,
    $add_defult_logformats=true,
    $server_name=$apache::params::server_name_default,
    $manage_service=true,
    $ssl_compression=$apache::params::ssl_compression_default,
    $ssl_protocol=$apache::params::ssl_protocol_default,
    $ssl_chiphersuite=$apache::params::ssl_chiphersuite_default,
    $manage_docker_service=false,
  )inherits apache::params {

  if($version!=$apache::version::default)
  {
    fail("unsupported version for this system - expected: ${version} supported: ${apache::version::default}")
  }

  validate_string($server_name)

  validate_array($listen)

  if($namevirtualhosts)
  {
    validate_array($namevirtualhosts)
  }

  package { $apache::params::packagename:
    ensure => 'installed',
    notify => Class['apache::service'],
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
      require => Package[$apache::params::packagename],
      content => template($apache::params::sysconfigtemplate),
    }
  }


  file { "${apache::params::baseconf}/conf.d":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    require => Package[$apache::params::packagename],
  }

  file { "${apache::params::baseconf}/conf.d/sites":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    require => File["${apache::params::baseconf}/conf.d"],
  }

  file { "${apache::params::baseconf}/${apache::params::conffile}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("apache/${apache::params::conftemplate}"),
    require => File["${apache::params::baseconf}/conf.d/sites"],
    notify  => Class['apache::service'],
  }

  concat { "${apache::params::baseconf}/conf.d/modules.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$apache::params::packagename],
    notify  => Class['apache::service'],
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
      recurse => true,
      purge   => true,
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
      notify  => Class['apache::service'],
      content => template("${module_name}/ssl/ssl.erb"),
    }
  }

  class { '::apache::service':
    manage_service        => $manage_service,
    manage_docker_service => $manage_docker_service,
  }

}
