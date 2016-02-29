
_osfamily               = fact('osfamily')
_operatingsystem        = fact('operatingsystem')
_operatingsystemrelease = fact('operatingsystemrelease').to_f

case _osfamily
when 'RedHat'
  $packagename     = 'httpd'
  $servicename     = 'httpd'
  $baseconf        = '/etc/httpd'
  $generalconf     = '/etc/httpd/conf/httpd.conf'
  $defaultsiteconf = '/etc/httpd/conf.d/00_default.conf'
  $et2blogconf     = '/etc/httpd/conf.d/sites/00-et2blog-80.conf'
  $et2blogconfssl  = '/etc/httpd/conf.d/sites/00-et2blog_ssl-443.conf'
  $systemadminconf = '/etc/httpd/conf.d/sites/10-systemadmin.es-81.conf'
  $testingconf     = '/etc/httpd/conf.d/sites/77-testing.lol-80.conf'
  $defaultvhconf   = '/etc/httpd/conf.d/00_default.conf'

when 'Debian'
  $packagename     = 'apache2'
  $servicename     = 'apache2'
  $baseconf        = '/etc/apache2'
  $generalconf     = '/etc/apache2/apache2.conf'
  $defaultsiteconf = '/etc/apache2/conf.d/00_default.conf'
  $et2blogconf     = '/etc/apache2/conf.d/sites/00-et2blog-80.conf'
  $et2blogconfssl  = '/etc/apache2/conf.d/sites/00-et2blog_ssl-443.conf'
  $systemadminconf = '/etc/apache2/conf.d/sites/10-systemadmin.es-81.conf'
  $testingconf     = '/etc/apache2/conf.d/sites/77-testing.lol-80.conf'
  $defaultvhconf   = '/etc/apache2/conf.d/00_default.conf'

else
  $packagename     = '-_-'
  $servicename     = '-_-'
  $baseconf        = '-_-'
  $defaultsiteconf = '-_-'
  $et2blogconf     = '-_-'
  $et2blogconfssl  = '-_-'
  $systemadminconf = '-_-'
  $defaultvhconf   = '-_-'

end
