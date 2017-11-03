# puppet2sitepp @apachevhostxfo
# ref: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
define apache::vhost::disablehttp10(
                                      $vhost_order = '00',
                                      $port        = '80',
                                      $servername  = $name,
                                    ) {
  #
  if(!defined(Concat::Fragment["${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run rewrite engine on"]))
  {
    concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run rewrite engine on":
      target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
      content => "\n  ## Rewrite rules ##\n\n  RewriteEngine On\n\n",
      order   => '05',
    }
  }

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run rewrites":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/rewrites/disablehttp10.erb"),
    order   => '06a',
  }

}
