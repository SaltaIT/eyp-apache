define apache::nss::intermediate(
                                  $intermediate_source,
                                  $aliasname = $name,
                                  $certdb    = '/etc/httpd/alias',
                                ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  file { "${apache::params::baseconf}/ssl/${aliasname}_intermediate.crt":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [
                Exec["generate db ${certdb}"],
                File["${apache::params::baseconf}/ssl"],
                Package[ [$apache::params::packagename, $apache::params::package_nss] ]
                ],
    source  => $intermediate_source,
  }

  exec { "certdb add intermediate ${aliasname} ${certdb}":
    command => "certutil -A -n '${aliasname}' -t 'CT,,' -d ${certdb} -f ${certdb}/pwdfile.txt -a -i ${apache::params::baseconf}/ssl/${aliasname}_intermediate.crt",
    require => File["${apache::params::baseconf}/ssl/${aliasname}_intermediate.crt"],
    unless  => "certutil -L -d ${certdb} | grep -E '\\b${aliasname}\\b'",
  }


}
