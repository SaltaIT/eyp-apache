#
# LoadModule auth_kerb_module modules/mod_auth_kerb.so
#
# <Location /secured>
# AuthType Kerberos
# AuthName “Kerberos Login”
# KrbMethodNegotiate On
# KrbMethodK5Passwd On
# KrbAuthRealms EXAMPLE.COM
# Krb5KeyTab /etc/httpd/conf/httpd.keytab
# require valid-user
# </Location>
#
define apache::kerberosauth(
                              $url,
                              $vhost_order       = '00',
                              $port              = '80',
                              $servername        = $name,
                              $authname          = undef,
                              $krb_keytab_source = undef,
                              $krb_authrealms    = undef,
                            ) {

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run ${directory}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/location/kerberosauth.erb"),
    order   => '03',
  }

}
