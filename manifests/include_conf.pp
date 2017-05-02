define apache::include_conf (
                              $path     = $name,
                              $files    = [ '*.conf' ],
                              $optional = true,
                              $order    = '42',
                            ) {

  include ::apache

  if(!defined(Concat["${apache::params::baseconf}/conf.d/includes.conf"]))
  {
    concat { "${apache::params::baseconf}/conf.d/includes.conf":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$apache::params::packagename],
      notify  => Class['apache::service'],
    }
  }

  concat::fragment { "include ${path} ${wildcard}":
    target  => "${apache::params::baseconf}/conf.d/includes.conf",
    order   => $order,
    content => template("${module_name}/includes.erb"),
  }

}
