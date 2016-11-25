class apache::mod::authz::svn(
                                $ensure = 'installed'
                              ) inherits apache {

  #TODO: en principi apache 2.4 only, verificar
  if($ensure=='installed')
  {
    apache::module { 'authz_svn_module':
      sofile  => "${apache::params::modulesdir}/mod_authz_svn.so",
      require => Class['::apache::mod::davsvn'],
      order   => '99',
    }
  }
}
