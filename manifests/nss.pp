define apache::nss(
                    $servername,
                    $vhost_order        = '00',
                    $port               = '80',
                    $nssalias           = $name,
                    $ciphersuite        = '+rsa_rc4_128_md5,+rsa_rc4_128_sha,+rsa_3des_sha,-rsa_des_sha,-rsa_rc4_40_md5,-rsa_rc2_40_md5,-rsa_null_md5,-rsa_null_sha,+fips_3des_sha,-fips_des_sha,-fortezza,-fortezza_rc4_128_sha,-fortezza_null,-rsa_des_56_sha,-rsa_rc4_56_sha,+rsa_aes_128_sha,+rsa_aes_256_sha',
                    $protocols          = [ 'TLSv1.0', 'TLSv1.1', 'TLSv1.2' ],
                    $certdb             = '/etc/httpd/alias',
                    $enforce_validcerts = true,
                  ) {
  #
  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run nss":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    order   => '02',
    content => template("${module_name}/nss/vhost_template.erb"),
    require => Apache::Nss::Cert[$nssalias],
  }

}
