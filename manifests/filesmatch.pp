#
# <Files ~ "\.(cgi|shtml|phtml|php3?)$">
#     SSLOptions +StdEnvVars
# </Files>
#
define apache::filesmatch (
                            $file_regex,
                            $ssl_options = [],
                            $vhost_order = '00',
                            $port        = '80',
                            $servername  = $name,
                            $description = undef,
                          ) {
  #

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run filesmatch ${file_regex}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/vhost/filesmatch.erb"),
    order   => '03',
  }
}
