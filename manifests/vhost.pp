#
define apache::vhost   (
        $documentroot,
        $order='00',
        $port='80',
        $defaultvh=false,
        $servername=$name,
        $serveralias=undef,
        $rewrites=undef,
        $rewrites_source=undef,
        $certname=undef,
        $use_intermediate=true,
        $certname_version='',
        $directoryindex=[ 'index.php', 'index.html', 'index.htm' ],
      ) {

    if ! defined(Class['apache'])
    {
      fail('You must include the apache base class before using any apache defined resources')
    }

    validate_string($servername)

    validate_absolute_path($documentroot)

    validate_string($servername)

    if($serveralias)
    {
      validate_array($serveralias)
    }

    if($rewrites)
    {
      validate_array($rewrites)
    }

    validate_array($directoryindex)

    Exec {
      path => '/sbin:/bin:/usr/sbin:/usr/bin',
    }

    exec { "mkdir p ${documentroot} ${servername} ${port}":
      command => "mkdir -p ${documentroot}",
      creates => $documentroot,
      require => Package[$apache::params::packagename],
    }

    if($defaultvh)
    {
      concat { "${apache::params::baseconf}/conf.d/00_default.conf":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service[$apache::params::servicename],
        require => Exec["mkdir p ${documentroot} ${servername} ${port}"]
      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/00_default.conf ini vhost":
        target  => "${apache::params::baseconf}/conf.d/00_default.conf",
        order   => '01',
        content => template("${module_name}/vhost/defaultvh.erb"),
      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/00_default.conf tanco vhost":
        target  => "${apache::params::baseconf}/conf.d/00_default.conf",
        content => "\n\n</VirtualHost>\n",
        order   => '99',
      }

      if($rewrites!=undef) or ($rewrites_source!=undef)
      {
        fail('rewriterules for the default vhost are unsupported')
      }

      file { $documentroot:
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        require => Exec["mkdir p ${documentroot} ${servername} ${port}"],
      }

    }
    else
    {
      #if ! defaultvh

      concat { "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Service[$apache::params::servicename],
        require => Exec["mkdir p ${documentroot} ${servername} ${port}"],
      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf ini vhost":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
        order   => '01',
        content => template("${module_name}/vhost/vhost.erb"),
      }

      if($certname!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf sslcert":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          order   => '02',
          content => template("${module_name}/ssl/vhost_template.erb"),
          require => File[  [
                              "${apache::params::baseconf}/ssl/${certname}_pk${certname_version}.pk",
                              "${apache::params::baseconf}/ssl/${certname}_cert${certname_version}.cert"
                            ]
                        ],
        }
      }

      if($rewrites!=undef) or ($rewrites_source!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf rewrite engine on":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  ## Rewrite rules ##\n  RewriteEngine On\n\n",
          order   => '05',
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf rewrites":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => template("${module_name}/rewrites/rewrites.erb"),
          order   => '06',
        }

        if($rewrites_source)
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf rewrite source":
            target => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
            source => $rewrites_source,
            order  => '07',
          }
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf rewrite END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n\n  ## END Rewrite rules ##\n\n",
          order   => '08',
        }

      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}.conf tanco vhost":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
        content => "\n\n</VirtualHost>\n",
        order   => '99',
      }

      #permetre documentroots comuns
      if(! defined(File[$documentroot]))
      {
        file { $documentroot:
          ensure  => 'directory',
          owner   => $apache::params::apache_username,
          group   => $apache::params::apache_username,
          mode    => '0775',
          require => Exec["mkdir p ${documentroot} ${servername} ${port}"],
        }
      }
    }
}
