define apache::nss::csr (
                          $cn,
                          $organization,
                          $organization_unit,
                          $locality,
                          $state,
                          $country,
                          $aliasname = $name,
                          $keysize   = '2048',
                          $certdb    = '/etc/httpd/alias',
                          $ensure    = 'present',
                        ) {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # CN=www.systemadmin.es,
  # O=systemadmin,
  # L=Barcelona,
  # ST=Barcelona
  # C=RC

  # certutil -R -s "CN=www.hereyourname.com, O=Networking4all B.V., L=Amsterdam, ST=Noord-Holland, C=NL" -o mycert.req -a -g 2048 -d /here/your/path/
  exec { "nss csr ${certdb} ${keysize} ${aliasname} ${name} ${country} ${state} ${location} ${organization} ${cn}":
    command => "strings /dev/urandom | certutil -R -s 'CN=${cn}, O=${organization}, OU=${organization_unit}, L=${locality}, ST=${state}, C=${country}' -o ${apache::params::baseconf}/ssl/${aliasname}.csr -a -g ${keysize} -d ${certdb} -f ${certdb}/pwdfile.txt",
    creates => "${apache::params::baseconf}/ssl/${aliasname}.csr",
    require => [
                Exec["generate db ${certdb}"],
                File["${apache::params::baseconf}/ssl"],
                Package[ [$apache::params::packagename, $apache::params::package_nss] ]
                ],
  }

  file { "${apache::params::baseconf}/ssl/${aliasname}.csr":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Exec["nss csr ${certdb} ${keysize} ${aliasname} ${name} ${country} ${state} ${location} ${organization} ${cn}"],
  }



}
