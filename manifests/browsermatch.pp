define apache::browsermatch (
                              $regex,
                              $set,
                              $vhost_order = '00',
                              $port        = '80',
                              $servername  = $name,
                              $description = undef,
                            ) {
  #
  validate_hash($set)

  concat::fragment{ "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run header ${condition} ${action} ${header_name} ${header_value}":
    target  => "${apache::params::baseconf}/conf.d/sites/${vhost_order}-${servername}-${port}.conf.run",
    content => template("${module_name}/browsermatch/browsermatch.erb"),
    order   => '19',
  }
}
