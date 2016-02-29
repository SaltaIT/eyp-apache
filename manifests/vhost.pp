#
# = vhost concat order
# 01 - vhost definition as in vhost/vhost.erb
# 02 - ssl configuration as in ssl/vhost_template.erb
# 03 - directory
# 05,06,07 - rewrite rules
# 08 - serverstatus
# 09,10,11 - aliasmatch
# 12,13,14 - scriptalias
# 16,17,18 - aliases
# 99 - end vhost
#
define apache::vhost   (
        $documentroot,
        $order            = '00',
        $port             = '80',
        $use_intermediate = true,
        $certname_version = '',
        $directoryindex   = [ 'index.php', 'index.html', 'index.htm' ],
        $defaultvh        = false,
        $defaultvh_ss     = true,
        $servername       = $name,
        $serveralias      = undef,
        $allowedip        = undef,
        $deniedip         = undef,
        $rewrites         = undef,
        $rewrites_source  = undef,
        $certname         = undef,
        $serveradmin      = undef,
        $aliasmatch       = undef,
        $scriptalias      = undef,
        $options          = $apache::params::options_default,
        $allowoverride    = $apache::params::allowoverride_default,
        $aliases          = undef,
        $add_default_logs = true,
      ) {

    if ! defined(Class['apache'])
    {
      fail('You must include the apache base class before using any apache defined resources')
    }

    if( $rewrites!=undef and $rewrites_source!=undef)
    {
      fail('Incompatible options: both rewrites and rewites_source are being defined')
    }

    validate_array($options)

    validate_string($allowoverride)

    if($deniedip)
    {
      validate_array($deniedip)
    }

    validate_string($servername)

    validate_absolute_path($documentroot)

    if($serveralias)
    {
      validate_array($serveralias)
    }

    if($rewrites)
    {
      validate_array($rewrites)
    }

    if($allowedip)
    {
      validate_array($allowedip)
    }

    if($aliasmatch)
    {
      validate_hash($aliasmatch)
    }

    if($aliases)
    {
      validate_hash($aliases)
    }

    if($scriptalias)
    {
      validate_hash($scriptalias)
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
      if($defaultvh_ss)
      {
        apache::serverstatus { "${servername} ${port} ${order} ${allowedip}":
          order            => $order,
          port             => $port,
          serverstatus_url => '/server-status',
          servername       => $servername,
          allowedip        => $allowedip,
          defaultvh        => true,
        }
      }

      concat { "${apache::params::baseconf}/conf.d/00_default.conf":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Class['apache::service'],
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
        notify  => Class['apache::service'],
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
          content => "\n  ## Rewrite rules ##\n\n  RewriteEngine On\n\n",
          order   => '05',
        }

        if($rewrites_source)
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf rewrite source":
            target => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
            source => $rewrites_source,
            order  => '06',
          }
        }
        else
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf rewrites":
            target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
            content => template("${module_name}/rewrites/rewrites.erb"),
            order   => '06',
          }
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf rewrite END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  ## END Rewrite rules ##\n\n",
          order   => '07',
        }

      }

      if($aliasmatch!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf aliasmatch BEGIN":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  ## AliasMatch BEGIN ##\n\n  <IfModule alias_module>\n\n",
          order   => '09',
        }
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf aliasmatch":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => template("${module_name}/aliasmatch/aliasmatch.erb"),
          order   => '10',
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf aliasmatch END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  </IfModule>\n\n  ## AliasMatch END##\n\n",
          order   => '11',
        }

      }

      if($scriptalias!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf scriptalias BEGIN":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  ## ScriptAlias BEGIN ##\n\n",
          order   => '12',
        }
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf scriptalias":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => template("${module_name}/scriptalias/scriptalias.erb"),
          order   => '13',
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf scriptalias END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  ## ScriptAlias END##\n\n",
          order   => '14',
        }

      }
      # Order 15 taken by directory define
      if($aliases!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf aliases BEGIN":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  ## Alias BEGIN ##\n\n  <IfModule alias_module>\n\n",
          order   => '16',
        }
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf aliases":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => template("${module_name}/aliases/aliases.erb"),
          order   => '17',
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf aliases END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf",
          content => "\n  </IfModule>\n\n  ## Alias END##\n\n",
          order   => '18',
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
