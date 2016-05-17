define apache::nss::cert(
                          $cert_source       = undef,
                          $aliasname         = $name,
                          $certdb            = '/etc/httpd/alias',
                          $selfsigned        = false,
                          $cn                = undef,
                          $organization      = undef,
                          $organization_unit = undef,
                          $locality          = undef,
                          $state             = undef,
                          $country           = undef,
                          $keysize           = '2048',
                          $months_valid      = '12000',
                        ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  if($selfsigned)
  {
    # crear certificat autofirmat
    exec { "nss selfsigned cert add ${aliasname} - ${certdb} - ${country} ${state} ${locality} ${organization} ${organization_unit} ${cn} ${name} ${aliasname}":
      command => "strings /dev/urandom | certutil -S -n ${aliasname} -t 'u,u,u' -s 'CN=${cn}, O=${organization}, OU=${organization_unit}, L=${locality}, ST=${state}, C=${country}' -x -v ${months_valid} -g ${keysize} -d ${certdb} -f ${certdb}/pwdfile.txt",
      unless  => "certutil -L -d ${certdb} | grep -E '\\b${aliasname}\\b'",
      require => [
                  Exec["generate db ${certdb}"],
                  File["${apache::params::baseconf}/ssl"],
                  Package[ [$apache::params::packagename, $apache::params::package_nss] ]
                  ],
    }
  }
  else
  {
    if($cert_source==undef)
    {
      fail('you must provide a signed certificate to import')
    }

    file { "${apache::params::baseconf}/ssl/${aliasname}_cert.crt":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [
                  Exec["generate db ${certdb}"],
                  File["${apache::params::baseconf}/ssl"],
                  Package[ [$apache::params::packagename, $apache::params::package_nss] ]
                  ],
      source  => $cert_source,
    }

    # certutil -A -n "www-hereyourname-com.cer" -t "P,," -d /here/your/path/ -a -i www-hereyourname-com.cer
    exec { "nss cert add ${aliasname} ${certdb}":
      command => "certutil -A -n '${aliasname}' -t 'P,,' -d ${certdb} -f ${certdb}/pwdfile.txt -a -i ${apache::params::baseconf}/ssl/${aliasname}_cert.crt",
      unless  => "certutil -L -d ${certdb} | grep -E '\\b${aliasname}\\b'",
      require => File["${apache::params::baseconf}/ssl/${aliasname}_cert.crt"],
    }
  }
}
