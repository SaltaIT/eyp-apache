#centos: mod_nss
#ubuntu: libapache2-mod-nss

class apache::mod::nss(
                        $ensure         = 'installed',
                        $randomseed     = [ 'builtin' ],
                        $certdb         = '/etc/httpd/alias',
                        $certdbpassword = 'CHANGEME_PASSWORD_CERTDB',
                        $ciphersuite    = '+rsa_rc4_128_md5,+rsa_rc4_128_sha,+rsa_3des_sha,-rsa_des_sha,-rsa_rc4_40_md5,-rsa_rc2_40_md5,-rsa_null_md5,-rsa_null_sha,+fips_3des_sha,-fips_des_sha,-fortezza,-fortezza_rc4_128_sha,-fortezza_null,-rsa_des_56_sha,-rsa_rc4_56_sha,+rsa_aes_128_sha,+rsa_aes_256_sha',
                        $protocols      = [ 'TLSv1.0', 'TLSv1.1', 'TLSv1.2' ],
                      ) inherits apache::params {

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  validate_array($randomseed)

  if($apache::ssl)
  {
    fail('to be able to enable mod_nss, please, disable mod_ssl first (apache::ssl)')
  }

  if($certdbpassword=='CHANGEME_PASSWORD_CERTDB')
  {
    fail('please, change certdb password')
  }

  if($ensure=='installed')
  {
    $ensure_conf_file='present'
  }
  elsif($ensure=='purged')
  {
    $ensure_conf_file='absent'
  }
  else
  {
    fail("unsupported ensure: ${ensure}")
  }

  package { $apache::params::package_nss:
    ensure => $ensure,
  }

  file { "${apache::params::baseconf}/conf.d/nss.conf":
    ensure  => $ensure_conf_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("${module_name}/nss/nss_base.erb"),
    require => Package[$apache::params::package_nss],
    notify  => Class['apache::service'],
  }

  #LoadModule nss_module modules/libmodnss.so
  apache::module { 'nss_module':
    sofile  => "${apache::params::modulesdir}/${apache::params::modnss_so}",
    order   => '00',
    require => Package[$apache::params::package_nss],
  }

  exec { "mkdir -p NSS ${certdb}":
    command => "mkdir -p ${certdb}",
    creates => $certdb,
  }

  file { $certdb:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Exec["mkdir -p NSS ${certdb}"],
  }

  #379  130416 143025 echo "blablablapassword" > pwdfile.txt
  file { "${certdb}/pwdfile.txt":
    ensure  => 'present',
    owner   => 'root',
    group   => $apache::params::apache_group,
    mode    => '0750',
    content => "${certdbpassword}\n",
    require => File[$certdb],
  }

  #380  130416 143026 echo "internal:blablablapassword" > pin.txt
  file { "${certdb}/pin.txt":
    ensure  => 'present',
    owner   => 'root',
    group   => $apache::params::apache_group,
    mode    => '0750',
    content => "internal:${certdbpassword}\n",
    require => File[$certdb],
  }

  exec { "generate db ${certdb}":
    command => "certutil -N -d ${certdb} -f ${certdb}/pwdfile.txt",
    creates => "${certdb}/cert8.db",
    require => File[ [ "${certdb}/pin.txt", "${certdb}/pwdfile.txt" ] ],
  }

  file { "${apache::params::baseconf}/ssl":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    require => Package[$apache::params::packagename],
  }

  # -rw------- 1 root root   65536 May 17 09:37 cert8.db
  # -rw------- 1 root root   16384 May 17 09:37 key3.db
  # -rw------- 1 root root   16384 May 17 09:37 secmod.db

  file { "${certdb}/cert8.db":
    ensure  => 'present',
    owner   => 'root',
    group   => $apache::params::apache_username,
    mode    => '0640',
    before  => Class['::apache::service'],
    require => Exec["generate db ${certdb}"],
  }

  file { "${certdb}/key3.db":
    ensure  => 'present',
    owner   => 'root',
    group   => $apache::params::apache_username,
    mode    => '0640',
    before  => Class['::apache::service'],
    require => Exec["generate db ${certdb}"],
  }

  file { "${certdb}/secmod.db":
    ensure  => 'present',
    owner   => 'root',
    group   => $apache::params::apache_username,
    mode    => '0640',
    before  => Class['::apache::service'],
    require => Exec["generate db ${certdb}"],
  }


}
