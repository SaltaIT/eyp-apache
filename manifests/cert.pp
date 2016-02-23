define apache::cert (
                      $pk_source,
                      $cert_source,
                      $intermediate_source=undef,
                      $certname=$name,
                      $version='',
                    ) {

  if ! defined(Class['apache'])
  {
    fail('You must include the apache base class before using any apache defined resources')
  }

  validate_string($pk_source)
  validate_string($cert_source)

  if($intermediate_source)
  {
    validate_string($intermediate_source)
  }

  file { "${apache::params::baseconf}/ssl/${certname}_pk${version}.pk":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
    notify  => Class['apache::service'],
    source  => $pk_source,
  }

  file { "${apache::params::baseconf}/ssl/${certname}_cert${version}.cert":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
    notify  => Class['apache::service'],
    source  => $cert_source,
  }

  if($intermediate_source!=undef)
  {
    validate_string($intermediate_source)

    file { "${apache::params::baseconf}/ssl/${certname}_intermediate${version}.cert":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
      notify  => Class['apache::service'],
      source  => $intermediate_source,
    }
  }

}
