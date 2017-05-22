define apache::browsermatch (
                              $regex,
                              $set,
                              $vhost_order = '00',
                              $port        = '80',
                              $servername  = $name,
                              $description = undef,
                            ) {
  #

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run browsermatch ${regex}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/browsermatch/browsermatch.erb"),
    order   => '19',
  }
}
