# puppet2sitepp @apacherequestheaders
define apache::requestheader (
                        $header_name,
                        $header_value = undef,
                        $action       = 'set',
                        $vhost_order  = '00',
                        $port         = '80',
                        $servername   = $name,
                        $description  = undef,
                      ) {

  include ::apache::mod::headers

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run requesheader ${action} ${header_name} ${header_value}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/headers/requestheader.erb"),
    order   => '20',
  }
}
