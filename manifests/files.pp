#
# <Files ~ "\.(cgi|shtml|phtml|php3?)$">
#     SSLOptions +StdEnvVars
# </Files>
#
# puppet2sitepp @apachefiles
define apache::files(
                      $file        = undef,
                      $file_regex  = undef,
                      $ssl_options = [],
                      $vhost_order = '00',
                      $port        = '80',
                      $servername  = $name,
                      $description = undef,
                    ) {
  #
  if($file!=undef and $file_regex!=undef)
  {
    fail('file and file_regex cannot be defined at the same time')
  }

  if($file==undef and $file_regex==undef)
  {
    fail('either file or file_regex must be defined')
  }

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run files ${file} ${file_regex}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/vhost/files.erb"),
    order   => '03',
  }
}
