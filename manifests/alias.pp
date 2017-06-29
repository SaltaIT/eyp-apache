define apache::alias(
                      $alias_from,
                      $alias_dir,
                      $servername  = $name,
                      $vhost_order = '00',
                      $port        = '80',
                    ) {

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run alias ${alias_from} ${alias_dir}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/aliases/alias.erb"),
    order   => '13',
  }
}
