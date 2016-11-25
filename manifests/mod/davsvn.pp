class apache::mod::davsvn (
                            $ensure = 'installed'
                          ) inherits apache {

  if($ensure=='installed')
  {
    apache::module { 'dav_svn_module':
      sofile  => "${apache::params::modulesdir}/mod_dav_svn.so",
    }
  }
}
