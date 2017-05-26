define apache::cacert (
                        $ca_source           = undef,
                        $ca_file             = undef,
                        $certname            = $name,
                        $version             = '',
                      ) {

  if ! defined(Class['apache'])
  {
    fail('You must include the apache base class before using any apache defined resources')
  }

  if($ca_source==undef and $ca_file==undef)
  {
    fail('both ca_source and ca_file are undefined')
  }

  if($ca_source!=undef)
  {
    validate_string($ca_source)
  }

  if($ca_file!=undef)
  {
    validate_absolute_path($ca_file)
  }

  if($ca_source!=undef)
  {
    file { "${apache::params::baseconf}/ssl/ca_${certname}_client_validation_${version}.pk":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
      source  => $ca_source,
      notify  => Class['apache::service'],
    }
  }
  else
  {
    file { "${apache::params::baseconf}/ssl/ca_${certname}_client_validation_${version}.pk":
      ensure => 'link',
      target => $ca_file,
      notify => Class['apache::service'],
    }
  }
}
