# puppet2sitepp @apachehsts
define apache::hsts (
                      $max_age            = '31536000',
                      $include_subdomains = false,
                      $preload            = false,
                      $vhost_order        = '00',
                      $port               = '80',
                      $servername         = $name,
                      $description        = undef,
                    ) {
  #
  include ::apache::mod::headers

  apache::header { "Strict-Transport-Security ${servername} ${vhost_order} ${port}":
    header_name  => 'Strict-Transport-Security',
    header_value => template("${module_name}/ssl/hsts.erb"),
    condition    => 'always',
    action       => 'set',
    vhost_order  => $vhost_order,
    port         => $port,
    servername   => $servername,
    description  => $description,
  }
}
