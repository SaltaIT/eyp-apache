# == Class: apache
#
# Full description of class apache here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the function of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'apache':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2015 Your name here, unless otherwise noted.
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
  )inherits apache::params {

  validate_array($listen)

  if($namevirtualhosts)
  {
    validate_array($namevirtualhosts)
  }

  package { $apache::params::packagename:
    ensure => "installed",
    notify => Service[$apache::params::servicename],
  }

  if($apache::params::packagenamedevel)
  {
    package { $apache::params::packagenamedevel:
      ensure => "installed",
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

  concat::fragment { "loadmodule header":
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
    name    => $apache::params::servicename,
    enable  => true,
    ensure  => "running",
    require => File["${baseconf}/${apache::params::conffile}"],
  }

}
