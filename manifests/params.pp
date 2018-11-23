class apache::params inherits apache::version {

  $servertokens_default='Prod'
  $timeout_default='30'
  $keepalive_default=true
  $keepalivetimeout_default=1
  $maxkeepalivereq_default=1000
  $extendedstatus_default=true
  $mpm_default='prefork'
  $serversignature_default=false
  $server_admin_default='root@localhost'
  $maxclients_default='256'
  $maxrequestsperchild_default='4000'
  $customlog_type_default='combined'
  $server_name_default = $::fqdn
  $site_enabled_default = true

  # Default directory options
  $options_default= [ 'FollowSymlinks' ]
  $allowoverride_default='None'
  $directory_default='/var/www/undef'

  $deflate_so='mod_deflate.so'
  $modexpires_so='mod_expires.so'
  $modproxy_so='mod_proxy.so'
  $modproxyajp_so='mod_proxy_ajp.so'
  $modproxyftp_so='mod_proxy_ftp.so'
  $modproxyhttp_so='mod_proxy_http.so'
  $modproxybalancer_so='mod_proxy_balancer.so'
  $modproxyconnect_so='mod_proxy_connect.so'
  $headers_so = 'headers.so'

  $apachectl='apachectl'

  #mod_nss
  #package: centos: mod_nss ubuntu: libapache2-mod-nss

  if(hiera('eypapache::pfs',false))
  {
    $ssl_chiphersuite_default=[ 'EECDH+ECDSA+AESGCM', 'EECDH+aRSA+AESGCM', 'EECDH+ECDSA+SHA384', 'EECDH+ECDSA+SHA256', 'EECDH+aRSA+SHA384', 'EECDH+aRSA+SHA256', 'EECDH+aRSA+RC4', 'EECDH', 'EDH+aRSA', 'RC4', '!aNULL', '!eNULL', '!LOW', '!3DES', '!MD5', '!EXP', '!PSK', '!SRP', '!DSS' ]
  }
  else
  {
    $ssl_chiphersuite_default=[ 'ECDHE-RSA-AES256-SHA384', 'AES256-SHA256', 'RC4', 'HIGH', '!MD5', '!aNULL', '!EDH', '!AESGCM' ]
  }

  case $::osfamily
  {
    'redhat':
    {
      $apache_default_shell = '/sbin/nologin'

      $baseconf='/etc/httpd'
      $modulesdir='modules'
      $loadmodules_extra=true
      $apache_username='apache'
      $apache_group='apache'
      $load_mpm_prefork=false
      $apache24=false
      $modssl_package= [ 'mod_ssl' ]
      $logdir='/var/log/httpd'
      $rotatelogsbin='/usr/sbin/rotatelogs'

      $sysconfigfile='/etc/sysconfig/httpd'
      $sysconfigtemplate="${module_name}/sysconfig/redhat/envvars.erb"

      $packagename=[ 'httpd' ]
      $packagenamedevel='httpd-devel'
      $servicename='httpd'
      $conftemplate='httpdconf_base.erb'
      $conffile='conf/httpd.conf'

      $ssl_compression_default=false

      $package_nss=[ 'mod_nss', 'nss-tools' ]
      $modnss_so='libmodnss.so'

      $kerberos_auth_package = 'mod_auth_kerb'
      $mod_ldap_package = 'mod_ldap'

      $dav_svn_package = 'mod_dav_svn'


      case $::operatingsystemrelease
      {
        /^5.*/:
        {
          $modsystemd=false
          $rundir='/var/run'
          $ssl_protocol_default=[ '-ALL', '+TLSv1' ]
          $snisupported=false
          $nss_pcache_path='/usr/sbin/nss_pcache'
          $ssl_session_cache_file_default = '/var/cache/mod_ssl/scache'
          $reqtimeout_so = undef
          $log_level_default = 'warn'

          $modphp_pkg=undef
          $modphp_so=undef
          $modphp_modulename=undef
        }
        /^6.*/:
        {
          $modsystemd=false
          $rundir='/var/run/httpd'
          $ssl_protocol_default=[ '-ALL', '+TLSv1', '+TLSv1.1', '+TLSv1.2' ]
          $snisupported=true
          $nss_pcache_path='/usr/libexec/nss_pcache'
          $ssl_session_cache_file_default = '/var/cache/mod_ssl/scache'
          $reqtimeout_so = 'mod_reqtimeout.so'
          $log_level_default = 'warn'

          $modphp_pkg=undef
          $modphp_so='libphp5.so'
          $modphp_modulename='php5_module'
        }
        /^7.*/:
        {
          $modsystemd=true
          $rundir='/var/run/httpd'
          $ssl_protocol_default=[ '-ALL', '+TLSv1', '+TLSv1.1', '+TLSv1.2' ]
          $snisupported=true
          $nss_pcache_path='/usr/libexec/nss_pcache'
          $ssl_session_cache_file_default = '/run/httpd/sslcache'
          $reqtimeout_so = 'mod_reqtimeout.so'
          $log_level_default = [ 'notice', 'core:info' ]

          $modphp_pkg=undef
          $modphp_so='libphp5.so'
          $modphp_modulename='php5_module'
        }
        default: { fail('Unsupported RHEL/CentOS version!')  }
      }
    }
    'Debian':
    {
      $apache_default_shell = '/usr/sbin/nologin'

      $baseconf='/etc/apache2'
      $modulesdir='/usr/lib/apache2/modules'
      $loadmodules_extra=false
      $apache_username='www-data'
      $apache_group='www-data'
      $load_mpm_prefork=true
      $apache24=true
      $logdir='/var/log/apache2'
      $rotatelogsbin='/usr/bin/rotatelogs'
      $rundir='/var/run/apache2'

      $sysconfigfile='/etc/apache2/envvars'
      $sysconfigtemplate="${module_name}/sysconfig/debian/envvars.erb"

      $ssl_compression_default=false

      $package_nss=[ 'libapache2-mod-nss' ]
      $modnss_so='mod_nss.so'
      $nss_pcache_path='/usr/sbin/nss_pcache'

      $kerberos_auth_package = 'libapache2-mod-auth-kerb'
      $mod_ldap_package = undef

      $ssl_session_cache_file_default = '/var/run/apache2/ssl_scache'

      $reqtimeout_so = 'mod_reqtimeout.so'

      $log_level_default = [ 'notice', 'core:info' ]

      case $::operatingsystem
      {
        'Ubuntu':
        {
          $packagenamedevel=undef
          $servicename='apache2'
          $conftemplate='httpdconf_base.erb'
          $conffile='apache2.conf'
          $modssl_package=[ 'apache2-bin' ]

          $ssl_protocol_default=[ '-ALL', '+TLSv1', '+TLSv1.1', '+TLSv1.2' ]
          $snisupported=true

          $modsystemd=false

          case $::operatingsystemrelease
          {
            /^14.*$/:
            {
              $packagename=[ 'apache2', 'apache2-mpm-prefork', 'apache2-utils', 'lynx-cur' ]
              $modphp_pkg=[ 'libapache2-mod-php5' ]

              $modphp_so='libphp5.so'
              $modphp_modulename='php5_module'
            }
            /^16.*$/:
            {
              $packagename=[ 'apache2', 'apache2-utils', 'lynx-cur' ]
              $modphp_pkg=[ 'libapache2-mod-php' ]

              $modphp_so='libphp7.0.so'
              $modphp_modulename='php7_module'
            }
            /^18.*$/:
            {
              $packagename=[ 'apache2', 'apache2-utils' ]
              $modphp_pkg=[ 'libapache2-mod-php' ]

              $modphp_so='libphp7.2.so'
              $modphp_modulename='php7_module'
            }
            default: { fail("Unsupported Ubuntu version! - ${::operatingsystemrelease}")  }
          }
        }
        'Debian': { fail('Unsupported')  }
        default: { fail('Unsupported Debian flavour!')  }
      }
    }
    default: { fail('Unsupported OS!')  }
  }
}
