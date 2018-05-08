#
# = vhost concat order
# 01 - vhost definition as in vhost/vhost.erb
# 02 - ssl configuration as in ssl/vhost_template.erb
# 02 - nss configuration as in nss/vhost_template.erb
# 03 - directory / location / files
# 04 - redirect
# 05,06,07 - rewrite rules
# 08 - serverstatus
# 09,10,11 - aliasmatch
# 12,13,14 - scriptalias
# 16,17,18 - aliases
# 19 - proxypass, proxypassreverse, proxyssl
# 20 - mod_headers
# 30 - location auth (kerberos...)
# 31 - browsermatch
# 99 - end vhost
#
# puppet2sitepp @apachevhosts
#
define apache::vhost(
                      $documentroot,
                      $description             = undef,
                      $order                   = '00',
                      $port                    = '80',
                      $listen_address          = '*',
                      $documentroot_owner      = 'root',
                      $documentroot_group      = 'root',
                      $documentroot_mode       = '0755',
                      $use_intermediate        = true,
                      $directoryindex          = [ 'index.php', 'index.html', 'index.htm' ],
                      $defaultvh               = false,
                      $defaultvh_ss            = true,
                      $servername              = $name,
                      $serveralias             = undef,
                      $allowedip               = undef,
                      $deniedip                = undef,
                      $rewrites                = undef,
                      $rewrites_source         = undef,
                      $certname                = undef,
                      $certname_version        = '',
                      $cacertname              = undef,
                      $cacertname_version      = '',
                      $serveradmin             = undef,
                      $aliasmatch              = undef,
                      $scriptalias             = undef,
                      $options                 = $apache::params::options_default,
                      $allowoverride           = $apache::params::allowoverride_default,
                      $aliases                 = undef,
                      $add_default_logs        = true,
                      $log_format              = 'combined',
                      $log_rotate_seconds      = '86400',
                      $customlog_filter        = undef,
                      $site_running            = $apache::params::site_enabled_default,
                      $custom_sorrypage        = undef,
                      $defaultcharset          = undef,
                      $includes                = [],
                      $includes_optional       = true,
                      $hsts                    = false,
                      $hsts_max_age            = '31536000',
                      $hsts_include_subdomains = false,
                      $hsts_preload            = false,
                      $ssl_verify_client       = 'none',
                      $ssl_verify_depth        = '1',
                      $allow_encoded_slashes   = false,
                    ) {

    if($custom_sorrypage)
    {
      validate_hash($custom_sorrypage)
      if !has_key($custom_sorrypage, 'path')
      {
        fail("Custom sorry page hash ${custom_sorrypage} does not contain 'path' key.")
      } else {
        validate_string($custom_sorrypage['path'])
      }
      if !has_key($custom_sorrypage, 'errordocument')
      {
        fail("Custom sorry page hash ${custom_sorrypage} does not contain 'errordocument' key.")
      } else {
        validate_string($custom_sorrypage['errordocument'])
      }
      if has_key($custom_sorrypage, 'healthcheck')
      {
        validate_string($custom_sorrypage['healthcheck'])
      }
    }

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

    if($hsts)
    {
      # $hsts_max_age            = '31536000',
      # $hsts_include_subdomains = false,
      # $hsts_preload            = false,
      apache::hsts { "Strict-Transport-Security ${servername} ${port} ${order}":
        max_age            => $hsts_max_age,
        include_subdomains => $hsts_include_subdomains,
        preload            => $hsts_preload,
        vhost_order        => $order,
        port               => $port,
        servername         => $servername,
        description        => 'Strict-Transport-Security',
      }
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
        require => [
                    Exec["mkdir p ${documentroot} ${servername} ${port}"],
                    File["${apache::params::baseconf}/conf.d"]
                    ],
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

      if(!defined(File[$documentroot]))
      {
        file { $documentroot:
          ensure  => 'directory',
          owner   => $documentroot_owner,
          group   => $documentroot_group,
          mode    => $documentroot_mode,
          require => Exec["mkdir p ${documentroot} ${servername} ${port}"],
        }
      }
    }
    else
    {
      #if ! defaultvh

      concat { "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Class['apache::service'],
        require => [
                    Exec["mkdir p ${documentroot} ${servername} ${port}"],
                    File["${apache::params::baseconf}/conf.d/sites"]
                    ],
      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run ini vhost":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
        order   => '01',
        content => template("${module_name}/vhost/vhost.erb"),
      }

      if($certname!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run sslcert":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
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
        if(!defined(Concat::Fragment["${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run rewrite engine on"]))
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run rewrite engine on":
            target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
            content => "\n  ## Rewrite rules ##\n\n  RewriteEngine On\n\n",
            order   => '05',
          }
        }

        if($rewrites_source)
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run rewrite source":
            target => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
            source => $rewrites_source,
            order  => '06',
          }
        }
        else
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run rewrites":
            target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
            content => template("${module_name}/rewrites/rewrites.erb"),
            order   => '06',
          }
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run rewrite END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => "\n  ## END Rewrite rules ##\n\n",
          order   => '07',
        }

      }

      if($aliasmatch!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run aliasmatch BEGIN":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => "\n  ## AliasMatch BEGIN ##\n\n  <IfModule alias_module>\n\n",
          order   => '09',
        }
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run aliasmatch":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => template("${module_name}/aliasmatch/aliasmatch.erb"),
          order   => '10',
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run aliasmatch END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => "\n  </IfModule>\n\n  ## AliasMatch END##\n\n",
          order   => '11',
        }

      }

      if($scriptalias!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run scriptalias BEGIN":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => "\n  ## ScriptAlias BEGIN ##\n\n",
          order   => '12',
        }
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run scriptalias":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => template("${module_name}/scriptalias/scriptalias.erb"),
          order   => '13',
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run scriptalias END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => "\n  ## ScriptAlias END##\n\n",
          order   => '14',
        }

      }
      # Order 15 taken by directory define
      if($aliases!=undef)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run aliases BEGIN":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => "\n  ## Alias BEGIN ##\n\n  <IfModule alias_module>\n\n",
          order   => '16',
        }
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run aliases":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => template("${module_name}/aliases/aliases.erb"),
          order   => '17',
        }

        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run aliases END":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
          content => "\n  </IfModule>\n\n  ## Alias END##\n\n",
          order   => '18',
        }

      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}.conf.run ${name} tanco vhost":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run",
        content => "\n\n</VirtualHost>\n",
        order   => '99',
      }

      ## Site disabled config ##
      concat { "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage":
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        notify  => Class['apache::service'],
        require => [
                    Exec["mkdir p ${documentroot} ${servername} ${port}"],
                    File["${apache::params::baseconf}/conf.d/sites"]
                    ],
      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage ini vhost":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
        order   => '01',
        content => template("${module_name}/vhost/sorry_vhost.erb"),
      }

      if($custom_sorrypage)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage custom sorrypage ini":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
          order   => '02',
          content => "\n  Alias /sorrypage ${custom_sorrypage['path']}\n  ErrorDocument 503 /sorrypage/${custom_sorrypage['errordocument']}\n",
        }
      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage rewrite on":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
        order   => '03',
        content => "\n  RewriteEngine On\n",
      }

      if($custom_sorrypage)
      {
        concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage custom sorrypage end":
          target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
          order   => '05',
          content => "\n  RewriteCond %{REQUEST_URI} !/sorrypage/.*\n",
        }

        if(has_key($custom_sorrypage, 'healthcheck'))
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage custom healtcheck":
            target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
            order   => '04',
            content => "\n  RewriteCond %{REQUEST_URI} !/${custom_sorrypage['healthcheck']}",
          }
        }

        if($certname!=undef)
        {
          concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage sslcert":
            target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
            order   => '02',
            content => template("${module_name}/ssl/vhost_template.erb"),
            require => File[  [
                              "${apache::params::baseconf}/ssl/${certname}_pk${certname_version}.pk",
                              "${apache::params::baseconf}/ssl/${certname}_cert${certname_version}.cert"
                              ]
                            ],
          }
        }

      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage redirect 503":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
        order   => '06',
        content => "  RewriteRule .* - [R=503,L]\n",
      }

      concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${order}-${servername}.conf.sorrypage ${name} tanco vhost":
        target  => "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage",
        content => "\n\n</VirtualHost>\n",
        order   => '99',
      }

      ## Vhost status ##

      if($site_running)
      {
        $site_status = "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.run"
      } else {
        $site_status = "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf.sorrypage"
      }

      file { "${apache::params::baseconf}/conf.d/sites/${order}-${servername}-${port}.conf":
        ensure => 'link',
        target => $site_status,
        notify => Class['apache::service'],
      }

      #permetre documentroots comuns
      if(! defined(File[$documentroot]))
      {
        file { $documentroot:
          ensure  => 'directory',
          owner   => $documentroot_owner,
          group   => $documentroot_group,
          mode    => $documentroot_mode,
          require => Exec["mkdir p ${documentroot} ${servername} ${port}"],
        }
      }
    }
}
