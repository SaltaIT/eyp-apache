# puppet2sitepp @apachemodules
define apache::module (
                        $sofile,
                        $modname = $name,
                        $order   = '42', #answer to life the universe and everything
                      ) {

  if ! defined(Class['apache'])
  {
    fail('You must include the apache base class before using any apache defined resources')
  }

  concat::fragment { "loadmodule ${sofile} ${modname}":
    target  => "${apache::params::baseconf}/conf.d/modules.conf",
    order   => $order,
    content => template("${module_name}/module/loadmodule.erb"),
  }
}
