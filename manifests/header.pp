# puppet2sitepp @apacheheaders
define apache::header (
                        $header_name,
                        $header_value,
                        $condition   = 'onsuccess',
                        $action      = 'set',
                        $vhost_order = '00',
                        $port        = '80',
                        $servername  = $name,
                        $description = undef,
                      ) {

  include ::apache::mod::headers

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run header ${name} ${condition} ${action} ${header_name} ${header_value}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/headers/header.erb"),
    order   => '20',
  }
}
