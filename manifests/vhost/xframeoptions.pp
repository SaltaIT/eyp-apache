# puppet2sitepp @apachevhostxfo
# ref: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/X-Frame-Options
define apache::vhost::xframeoptions(
                                      $deny        = true,
                                      $sameorigin  = false,
                                      $allow_from  = undef,
                                      $vhost_order = '00',
                                      $port        = '80',
                                      $servername  = $name,
                                      $description = "X-Frame-Options",
                                    ) {
  #
  include ::apache::mod::headers

  apache::header { "X-Frame-Options ${servername} ${vhost_order} ${port}":
    header_name  => 'X-Frame-Options',
    header_value => template("${module_name}/vhost/xfo.erb"),
    condition    => 'always',
    action       => 'set',
    vhost_order  => $vhost_order,
    port         => $port,
    servername   => $servername,
    description  => $description,
  }
}
