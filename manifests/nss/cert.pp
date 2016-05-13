define apache::nss::cert(
                          $cert_source,
                          $aliasname = $name,
                          $certdb    = '/etc/httpd/alias',
                        ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
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
