class apache::params {

	$servertokens_default="Prod"
	$timeout_default=30
	$keepalive_default=true
	$keepalivetimeout_default=1
	$maxkeepalivereq_default=1000
	$extendedstatus_default=true
	$mpm_default="prefork"
	$serversignature_default=false

	case $::osfamily
	{
		'redhat':
    		{
					$baseconf='/etc/httpd'
					$modulesdir='modules'
					$loadmodules_extra=true
					$apache_username='apache'
					$load_mpm_prefork=false
					$apache24=false
					$modssl_package= [ 'mod_ssl' ]

					$fastcgi_dependencies= [ 'make', 'gcc', 'gcc-c++' ]


			case $::operatingsystemrelease
			{
				/^[67].*$/:
				{
					$packagename='httpd'
					$packagenamedevel='httpd-devel'
					$servicename='httpd'
					$conftemplate='httpdconfcentos6.erb'
					$conffile='conf/httpd.conf'
				}
				default: { fail("Unsupported RHEL/CentOS version!")  }
			}
		}
		'Debian':
		{
			#
			# QUICK & DIRTY
			#

			$baseconf='/etc/apache2'
			$modulesdir='/usr/lib/apache2/modules'
			$loadmodules_extra=false
			$apache_username='www-data'
			$load_mpm_prefork=true
			$apache24=true

			case $::operatingsystem
			{
				'Ubuntu':
				{
					case $::operatingsystemrelease
					{
						/^14.*$/:
						{
							$packagename=[ 'apache2', 'apache2-mpm-prefork' ]
							$servicename='apache2'
							$conftemplate='httpdconfcentos6.erb'
							$conffile='apache2.conf'
						}
						default: { fail("Unsupported Ubuntu version! - $::operatingsystemrelease")  }
					}
				}
				'Debian': { fail("Unsupported")  }
				default: { fail("Unsupported Debian flavour!")  }
			}
		}
		default: { fail("Unsupported OS!")  }
	}
}
