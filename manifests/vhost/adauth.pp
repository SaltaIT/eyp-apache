#
# puppet2sitepp @apachevhostadauth
#
define apache::vhost::adauth(
                              $url,
                              $auth_ldap_url,
                              $auth_ldap_bind_dn,
                              $auth_ldap_bind_password,
                              $vhost_order                     = '00',
                              $port                            = '80',
                              $servername                      = $name,
                              $authname                        = undef,
                              $auth_ldap_group_attribute       = 'member',
                              $auth_ldap_group_attribute_is_dn = true,
                              $requisites                      = [ 'valid-user' ],
                            ) {
  #
  # apache 2.4
  #
  # yum install mod_ldap
  #
  # /etc/httpd/conf/httpd.conf:LoadModule ldap_module modules/mod_ldap.so
  # /etc/httpd/conf/httpd.conf:LoadModule authnz_ldap_module modules/mod_authnz_ldap.so
  #
  # LDAPVerifyServerCert off
  #
  # AuthName "AD authentication"
  # AuthBasicProvider ldap
  # AuthType Basic
  # AuthLDAPGroupAttribute member
  # AuthLDAPGroupAttributeIsDN On
  # AuthLDAPURL "ldaps://srv-ad02.nttcom.ms.local/OU=NTTCMS,DC=nttcom,DC=ms,DC=local?sAMAccountName?sub?(objectClass=user)"
  # AuthLDAPBindDN  "cn=auth GBM,OU=Service Account,OU=NTTCMS,DC=nttcom,DC=ms,DC=local"
  # AuthLDAPBindPassword "XXXXXXXX"
  # AuthUserFile /dev/null
  # Require valid-user
  #
  include ::apache::mod::ldap

  if($apache::params::mod_ldap_package!=undef)
  {
    if(! defined(Package[$apache::params::mod_ldap_package]))
    {
      package { $apache::params::mod_ldap_package:
        ensure => 'installed',
        before => Apache::Module['ldap_module'],
      }
    }
  }

  if(!defined(Apache::Module['ldap_module']))
  {
    #LoadModule auth_kerb_module modules/mod_auth_kerb.so
    apache::module { 'ldap_module':
      sofile  => "${apache::params::modulesdir}/mod_ldap.so",
    }
  }

  $url_cleanup = regsubst($url, '[^a-zA-Z]+', '')

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run ADauth ${url}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/location/adauth.erb"),
    order   => '03',
  }
}
