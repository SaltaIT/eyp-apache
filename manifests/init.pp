# @param add_conf_audit_rules Add audit rules for httpd config files (default: false)
class apache(
              $mpm                       = $apache::params::mpm_default,
              $servertokens              = $apache::params::servertokens_default,
              $timeout                   = $apache::params::timeout_default,
              $keepalive                 = $apache::params::keepalive_default,
              $keepalivetimeout          = $apache::params::keepalivetimeout_default,
              $maxkeepalivereq           = $apache::params::maxkeepalivereq_default,
              $extendedstatus            = $apache::params::extendedstatus_default,
              $serversignature           = $apache::params::serversignature_default,
              $listen                    = [ '80' ],
              $namevirtualhosts          = undef,
              $ssl                       = false,
              $sni                       = true,
              $ssl_honor_cipher_order    = true,
              $ssl_compression           = $apache::params::ssl_compression_default,
              $ssl_protocol              = $apache::params::ssl_protocol_default,
              $ssl_chiphersuite          = $apache::params::ssl_chiphersuite_default,
              $ssl_use_stapling          = false,
              $trace                     = false,
              $version                   = $apache::version::default,
              $apache_username           = $apache::params::apache_username,
              $apache_group              = $apache::params::apache_group,
              $manage_apache_user_shell  = true,
              $apache_user_shell         = $apache::params::apache_default_shell,
              $server_admin              = $apache::params::server_admin_default,
              $directoty_index           = [ 'index.html' ],
              $maxclients                = $apache::params::maxclients_default,
              $maxrequestsperchild       = $apache::params::maxrequestsperchild_default,
              $customlog_type            = $apache::params::customlog_type_default,
              $logformats                = undef,
              $add_defult_logformats     = true,
              $server_name               = $apache::params::server_name_default,
              $manage_service            = true,
              $systemd_socket_activation = false,
              $manage_docker_service     = false,
              $defaultcharset            = 'UTF-8',
              $loglevel_errorlog         = $apache::params::log_level_default,
              $usecanonicalname          = false,
              $default_documentroot      = '/var/www/html',
              $accessfilename            = '.htaccess',
              $hostnamelookups           = false,
              $purge_logrotate           = true,
              $compress_logs_mtime       = undef,
              $delete_logs_mtime         = undef,
              $logdir                    = $apache::params::logdir,
              $umask                     = undef,
              $startservers              = '8',
              $minspareservers           = '5',
              $maxspareservers           = '20',
              $selinux_httpd_use_nfs     = false,
              $root_directory_deny       = true,
              $ssl_session_cache_type    = 'shmcb',
              $ssl_session_cache_file    = $apache::params::ssl_session_cache_file_default,
              $ssl_session_cache_size    = '512000',
              $add_conf_audit_rules      = false,
              $limit_request_line        = undef,
              $limit_request_fields      = undef,
              $limit_request_field_size  = undef,
              $limit_request_body        = undef,
              $enable_autoindex          = true,
              $default_follow_sym_links  = true,
              $confd_purge               = true,
              $confd_recurse             = true,
            ) inherits apache::params {

  if($version!=$apache::version::default)
  {
    fail("unsupported version for this system - expected: ${version} supported: ${apache::version::default}")
  }

  # LoadModule autoindex_module <%= scope.lookupvar('apache::params::modulesdir') %>/mod_autoindex.so
  if($enable_autoindex)
  {
    apache::module { 'autoindex_module':
      sofile  => "${apache::params::modulesdir}/mod_autoindex.so",
      require => Package[$apache::params::packagename],
      before  => Class['apache::service'],
    }
  }

  if($manage_apache_user_shell)
  {
    user { $apache_username:
      ensure  => 'present',
      gid     => $apache_group,
      shell   => $apache_user_shell,
      require => Package[$apache::params::packagename],
      before  => Class['apache::service'],
    }
  }

  if(defined(Class['::audit']))
  {
    # # Watch Apache configuration
    # -w /etc/httpd/conf/ -p rwa -k apacheConfigAccess
    # -w <%= @path %> -p <%= @permissions %> -k <%= @keyname %>
    # define audit::fsrule(
    #                   $path,
    #                   $permissions,
    #                   $keyname = $name,
    #                 ) {
    if($add_conf_audit_rules)
    {
      audit::fsrule { 'apacheConfigAccess-conf':
        path        => "${apache::params::baseconf}/conf",
        permissions => 'rwa',
        keyname     => 'apacheConfigAccess',
      }

      audit::fsrule { 'apacheConfigAccess-confd':
        path        => "${apache::params::baseconf}/conf.d",
        permissions => 'rwa',
        keyname     => 'apacheConfigAccess',
      }
    }
  }

  if(defined(Class['::selinux']))
  {
    $current_selinux_mode = $::selinux? {
      bool2boolstr(false) => 'disabled',
      false               => 'disabled',
      default             => $::selinux_current_mode,
    }

    case $current_selinux_mode
    {
      /^(enforcing|permissive)$/:
      {
        selinux::setbool { 'httpd_use_nfs':
          value => $selinux_httpd_use_nfs,
        }
      }
      'disabled': { }
      default: { fail('this should not happen') }
    }
  }

  validate_string($server_name)

  validate_array($listen)

  if($namevirtualhosts)
  {
    validate_array($namevirtualhosts)
  }

  package { $apache::params::packagename:
    ensure => 'installed',
    notify => Class['apache::service'],
  }

  if($apache::params::packagenamedevel!=undef)
  {
    package { $apache::params::packagenamedevel:
      ensure => 'installed',
    }
  }

  case $::osfamily
  {
    'Debian':
    {
      case $::operatingsystem
      {
        'Ubuntu':
        {
          case $::operatingsystemrelease
          {
            /^16.*$/:
            {
              exec { 'kill zombie apache':
                command => "systemctl stop ${apache::params::servicename} || /bin/true",
                require => Package[$apache::params::packagename],
                before  => File["${apache::params::baseconf}/conf.d/sites"],
                unless  => "test -d ${apache::params::baseconf}/conf.d/sites",
                path    => '/usr/sbin:/usr/bin:/sbin:/bin',
              }
            }
            default: { }
          }
        }
        default: { }
      }
    }
    default: { }
  }

  if($apache::params::sysconfigfile!=undef and $apache::params::sysconfigtemplate!=undef)
  {
    file { $apache::params::sysconfigfile:
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$apache::params::packagename],
      content => template($apache::params::sysconfigtemplate),
    }
  }


  file { "${apache::params::baseconf}/conf.d":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => $confd_recurse,
    purge   => $confd_purge,
    require => Package[$apache::params::packagename],
  }

  file { "${apache::params::baseconf}/conf.d/sites":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    require => File["${apache::params::baseconf}/conf.d"],
  }

  file { "${apache::params::baseconf}/${apache::params::conffile}":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("apache/${apache::params::conftemplate}"),
    require => File["${apache::params::baseconf}/conf.d/sites"],
    notify  => Class['apache::service'],
  }

  concat { "${apache::params::baseconf}/conf.d/modules.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$apache::params::packagename],
    notify  => Class['apache::service'],
  }

  concat { "${apache::params::baseconf}/conf.d/global.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package[$apache::params::packagename],
    notify  => Class['apache::service'],
  }

  concat::fragment { "globalconf header ${apache::params::baseconf}":
    target  => "${apache::params::baseconf}/conf.d/global.conf",
    order   => '00', #answer to life the universe and everything
    content => "# puppet managed file\n",
  }

  concat::fragment { "loadmodule header ${apache::params::baseconf}":
    target  => "${apache::params::baseconf}/conf.d/modules.conf",
    order   => '00', #answer to life the universe and everything
    content => "# puppet managed file\n",
  }

  if($ssl)
  {
    package { $apache::params::modssl_package:
      ensure => 'installed',
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

    file { "${apache::params::baseconf}/conf.d/ssl.conf":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require =>  [
                    File["${apache::params::baseconf}/conf.d"],
                    Package[[$apache::params::packagename, $apache::params::modssl_package]]
                  ],
      notify  => Class['apache::service'],
      content => template("${module_name}/ssl/ssl.erb"),
    }
  }

  class { '::apache::service':
    manage_service            => $manage_service,
    manage_docker_service     => $manage_docker_service,
    systemd_socket_activation => $systemd_socket_activation,
  }

  if($purge_logrotate)
  {
    if(defined(Class['logrotate']))
    {
      logrotate::logs { $apache::params::servicename:
        ensure      => 'absent',
        custom_file => "/etc/logrotate.d/${apache::params::servicename}",
      }
    }
  }

  if($compress_logs_mtime!=undef)
  {
    validate_re($compress_logs_mtime, [ '^\+[0-9]+$' ], 'not a valid mtime value')

    if(defined(Class['purgefiles']))
    {
      purgefiles::cronjob { 'eyp-apache logdir compress':
        path        => $logdir,
        file_iname  => '\*.log',
        mtime       => $compress_logs_mtime,
        action      => '-exec gzip {} \;',
        cronjobname => 'eyp-apache logdir compress',
      }
    }
  }

  #delete_logs_mtime
  if($delete_logs_mtime!=undef)
  {
    validate_re($delete_logs_mtime, [ '^\+[0-9]+$' ], 'not a valid mtime value')

    if(defined(Class['purgefiles']))
    {

      if($compress_logs_mtime!=undef)
      {
        purgefiles::cronjob { 'eyp-apache logdir purge old logs':
          path        => $logdir,
          file_iname  => '\*.log.gz',
          mtime       => $delete_logs_mtime,
          cronjobname => 'eyp-apache logdir purge old logs',
        }
      }
      else
      {
        purgefiles::cronjob { 'eyp-apache logdir purge old logs':
          path        => $logdir,
          file_iname  => '\*.log',
          mtime       => $delete_logs_mtime,
          cronjobname => 'eyp-apache logdir purge old logs',
        }
      }
    }
  }

}
