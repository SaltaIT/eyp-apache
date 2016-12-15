class apache::mod::davsvn (
                            $ensure = 'installed'
                          ) inherits apache {

  #$dav_svn_package = 'mod_dav_svn'
  package { $apache::params::dav_svn_package:
    ensure => 'installed',
  }

  if($ensure=='installed')
  {
    apache::module { 'dav_svn_module':
      sofile  => "${apache::params::modulesdir}/mod_dav_svn.so",
      require => Package[$apache::params::dav_svn_package],
    }
  }
}
