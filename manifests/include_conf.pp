# puppet2sitepp @apacheincludesconf
define apache::include_conf (
                              $path        = $name,
                              $files       = [ '*.conf' ],
                              $optional    = true,
                              $order       = '42',
                              $description = undef,
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

  concat::fragment { "include ${path} ${files}":
    target  => "${apache::params::baseconf}/conf.d/includes.conf",
    order   => $order,
    content => template("${module_name}/includes.erb"),
  }

}
