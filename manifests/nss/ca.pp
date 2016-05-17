define apache::nss::ca(
                          $cn,
                          $months_valid = '12000',
                          $serialnumber = '1',
                          $caname = $name,
                          $certdb = '/etc/httpd/alias',
                        ) {
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # certutil -A -n "www-hereyourname-com.cer" -t "P,," -d /here/your/path/ -a -i www-hereyourname-com.cer
  exec { "nss CA ${caname} ${certdb}":
    command => "strings /dev/urandom | certutil -S -s 'CN=${cn}' -n ${caname} -x -t 'CT,C,C' -v ${months_valid} -m ${serialnumber} -d ${certdb} -f ${certdb}/pwdfile.txt",
    unless  => "certutil -L -d ${certdb} | grep -E '\\b${caname}\\b'",
    require => [
                Exec["generate db ${certdb}"],
                File["${apache::params::baseconf}/ssl"],
                Package[ [$apache::params::packagename, $apache::params::package_nss] ]
                ],
  }

}
