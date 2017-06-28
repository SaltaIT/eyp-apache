define apache::alias(
                      $alias,
                      $dir,
                      $servername  = $name,
                      $vhost_order = '00',
                      $port        = '80',
                    ) {

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run alias ${alias} ${dir}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/aliases/alias.erb"),
    order   => '13',
  }
}
