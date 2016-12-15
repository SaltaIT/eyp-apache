define apache::davsvnrepo(
                            $url,
                            $svnpath,
                            $svn_access_file_source = undef,
                            $vhost_order            = '00',
                            $port                   = '80',
                            $servername             = $name,
                            $authname               = undef,
                            #kerberos
                            $use_kerberos           = false,
                            $krb_authrealms         = undef,
                            $krb_keytab_source      = undef,
                            $method_negotiate       = true,
                            $method_k5_passwd       = true,
                          ) {
  # LoadModules
  include ::apache::mod::davsvn
  include ::apache::mod::authz::svn

  if($use_kerberos)
  {
    if(! defined(Package[$apache::params::kerberos_auth_package]))
    {
      package { $apache::params::kerberos_auth_package:
        ensure => 'installed',
      }
    }

    if(!defined(Apache::Module['auth_kerb_module']))
    {
      #LoadModule auth_kerb_module modules/mod_auth_kerb.so
      apache::module { 'auth_kerb_module':
        sofile  => "${apache::params::modulesdir}/mod_auth_kerb.so",
        require => Package[$apache::params::kerberos_auth_package],
      }
    }

    $url_cleanup = regsubst($url, '[^a-zA-Z]+', '')

    validate_array($krb_authrealms)

    validate_string($krb_keytab_source)

    file { "${apache::params::baseconf}/conf.d/keytabs/${vhost_order}-${servername}-${port}-${url_cleanup}.davsvn.keytab":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => [
                  Package[$apache::params::kerberos_auth_package],
                  File["${apache::params::baseconf}/conf.d/keytabs"]
                  ],
      notify  => Class['apache::service'],
      source  => $krb_keytab_source,
    }

    if(! defined(File["${apache::params::baseconf}/conf.d/keytabs"]))
    {
      file { "${apache::params::baseconf}/conf.d/keytabs":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
        purge   => true,
        require => File["${apache::params::baseconf}/conf.d"],
      }
    }
  }

  if($svn_access_file_source)
  {
    if(! defined(File["${apache::params::baseconf}/conf.d/svnacls"]))
    {
      file { "${apache::params::baseconf}/conf.d/svnacls":
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        recurse => true,
        purge   => true,
        require => File["${apache::params::baseconf}/conf.d"],
      }
    }

    file { "${apache::params::baseconf}/conf.d/svnacls/${vhost_order}-${servername}-${port}-${url_cleanup}.acl":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => File["${apache::params::baseconf}/conf.d/svnacls"],
      notify  => Class['apache::service'],
      source  => $svn_access_file_source,
    }

  }

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run ${url} ${svnpath}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/location/davsvnrepo.erb"),
    order   => '03',
  }

}
