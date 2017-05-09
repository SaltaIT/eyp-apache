define apache::addtype(
                        $mediatype,
                        $extension   = $name,
                        $description = undef,
                        $order       = '42',
                      ) {
  include ::apache

  if(!defined(Concat["${apache::params::baseconf}/conf.d/types.conf"]))
  {
    concat { "${apache::params::baseconf}/conf.d/types.conf":
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package[$apache::params::packagename],
      notify  => Class['apache::service'],
    }
  }

  concat::fragment { "addtype ${mediatype} ${extension}":
    target  => "${apache::params::baseconf}/conf.d/types.conf",
    order   => $order,
    content => template("${module_name}/addtype.erb"),
  }
}
