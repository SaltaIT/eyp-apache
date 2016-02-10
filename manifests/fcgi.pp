class apache::fcgi (
                      $srcdir='/usr/local/src',
                      $handler_name=$name,
                      $fcgihost='127.0.0.1',
                      $fcgiport='9000',
                    ) inherits apache::params {

  # <IfModule mod_fastcgi.c>
  #   AddHandler php5-fcgi .php
  #   Action php5-fcgi /php5-fcgi
  #   Alias /php5-fcgi /usr/lib/cgi-bin/php5-fcgi
  #   FastCgiExternalServer /usr/lib/cgi-bin/php5-fcgi -host 127.0.0.1:9000 -pass-header Authorization
  # </IfModule>

  Exec {
    path => '/usr/sbin:/usr/bin:/sbin:/bin',
  }

  define install_fcgi_dependencies {
    package { "dependencia fastcgi ${name}":
      ensure => 'installed',
      name   => $name,
    }
  }

  install_fcgi_dependencies { $apache::params::fastcgi_dependencies: }

  exec { "mkdir ${srcdir} fastcgi":
    command => "mkdir -p ${srcdir}",
    creates => $srcdir,
    require => Install_fcgi_dependencies[$apache::params::fastcgi_dependencies],
  }

  exec { "mkdir ${srcdir} fastcgifastcgi":
    command => "mkdir -p ${srcdir}/mod_fastcgi",
    creates => "${srcdir}/mod_fastcgi",
  }

  exec { "wget ${srcdir} fastcgi":
    command => "wget http://www.fastcgi.com/dist/mod_fastcgi-current.tar.gz -O ${srcdir}/mod_fastcgi-current.tar.gz",
    creates => "${srcdir}/mod_fastcgi-current.tar.gz",
    require => Exec["mkdir ${srcdir} fastcgi"],
  }

  exec { "tar xf ${srcdir}/mod_fastcgi-current.tar.gz -C ${srcdir}/mod_fastcgi":
    command => "tar xzf ${srcdir}/mod_fastcgi-current.tar.gz --strip-components =1 -C ${srcdir}/mod_fastcgi",
    cwd     => $srcdir,
    creates => "${srcdir}/mod_fastcgi/Makefile.AP2",
    require => Exec["wget ${srcdir} fastcgi","mkdir ${srcdir} fastcgifastcgi"],
  }

  exec { "make fastcgi ${srcdir}":
    command => 'make -f Makefile.AP2 top_dir =/usr/lib64/httpd/',
    cwd     => "${srcdir}/mod_fastcgi",
    require => [
                Package[$apache::params::packagenamedevel],
                Exec["tar xf ${srcdir}/mod_fastcgi-current.tar.gz -C ${srcdir}/mod_fastcgi"]
              ],
    creates => "${srcdir}/mod_fastcgi/.libs/mod_fastcgi.so",
  }

  exec { "install fastcgi ${srcdir}":
    require => Exec["make fastcgi ${srcdir}"],
    cwd     => "${srcdir}/mod_fastcgi",
    command => 'cp .libs/mod_fastcgi.so /usr/lib64/httpd/modules/',
    creates => '/usr/lib64/httpd/modules/mod_fastcgi.so',
  }

  exec { 'mkdir p /usr/lib/cgi-bin fastcgi':
    command => 'mkdir -p /usr/lib/cgi-bin',
    creates => '/usr/lib/cgi-bin',
    before  => File["${apache::params::baseconf}/conf.d/fcgi.conf"],
  }

  file { "${apache::params::baseconf}/conf.d/fcgi.conf":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service[$apache::params::servicename],
    content => template("${module_name}/module/fcgihandler.erb"),
    require => Exec["install fastcgi ${srcdir}"],
  }


}
