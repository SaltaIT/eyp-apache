# LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
define apache::logformat(
                          $logformat,
                          $logformat_name = $name,
                          $description    = undef,
                        ) {

  concat::fragment{ "${apache::params::baseconf}/conf.d/global.conf logformat ${logformat_name}":
    target  => "${apache::params::baseconf}/conf.d/global.conf",
    content => template("${module_name}/logformat.erb"),
    order   => '99',
  }
}
