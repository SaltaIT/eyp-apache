define apache::cert (
                      $pk_source=undef,
                      $pk_file=undef,
                      $cert_source=undef,
                      $cert_file=undef,
                      $intermediate_source=undef,
                      $certname=$name,
                      $version='',
                    ) {

  if ! defined(Class['apache'])
  {
    fail('You must include the apache base class before using any apache defined resources')
  }

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
    validate_string($pk_source)
  }

  if($cert_source!=undef)
  {
    validate_string($cert_source)
  }

  if($pk_file!=undef)
  {
    validate_absolute_path($pk_file)
  }

  if($cert_file!=undef)
  {
    validate_absolute_path($cert_file)
  }

  if($intermediate_source!=undef)
  {
    validate_string($intermediate_source)
  }

  if($pk_source!=undef)
  {
    file { "${apache::params::baseconf}/ssl/${certname}_pk${version}.pk":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [ Package[$apache::params::packagename], File["${apache::params::baseconf}/ssl"] ],
      notify  => Class['apache::service'],
      source  => $pk_source,
    }
  }
  else
  {
    file { "${apache::params::baseconf}/ssl/${certname}_pk${version}.pk":
      ensure => 'link',
      target => $pk_file,
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
      notify  => Class['apache::service'],
      source  => $cert_source,
    }
  }
  else
  {
    file { "${apache::params::baseconf}/ssl/${certname}_cert${version}.cert":
      ensure => 'link',
      target => $cert_file,
    }
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
