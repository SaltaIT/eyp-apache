# puppet2sitepp @apachecerts
define apache::cert (
                      $pk_source           = undef,
                      $pk_file             = undef,
                      $cert_source         = undef,
                      $cert_file           = undef,
                      $intermediate_source = undef,
                      $intermediate_file   = undef,
                      $certname            = $name,
                      $version             = '',
                    ) {

  include ::apache

  if($pk_source==undef and $pk_file==undef)
  {
    fail('both pk_source and pk_file are undefined')
  }

  if($cert_source==undef and $cert_file==undef)
  {
    fail('both cert_source and cert_file are undefined')
  }

  if($pk_source!=undef)
  {
    file { "${apache::params::baseconf}/ssl/${certname}_pk${version}.pk":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
      source  => $pk_source,
      notify  => Class['apache::service'],
    }
  }
  else
  {
    file { "${apache::params::baseconf}/ssl/${certname}_pk${version}.pk":
      ensure => 'link',
      target => $pk_file,
      notify => Class['apache::service'],
    }
  }


  if($cert_source!=undef)
  {
    file { "${apache::params::baseconf}/ssl/${certname}_cert${version}.cert":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
      source  => $cert_source,
      notify  => Class['apache::service'],
    }
  }
  else
  {
    file { "${apache::params::baseconf}/ssl/${certname}_cert${version}.cert":
      ensure => 'link',
      target => $cert_file,
      notify => Class['apache::service'],
    }
  }


  if($intermediate_source!=undef)
  {

    file { "${apache::params::baseconf}/ssl/${certname}_intermediate${version}.cert":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
      source  => $intermediate_source,
      notify  => Class['apache::service'],
    }
  }
  else
  {
    file { "${apache::params::baseconf}/ssl/${certname}_intermediate${version}.cert":
    ensure => 'link',
    target => $intermediate_file,
    notify => Class['apache::service'],
    }
  }

}
