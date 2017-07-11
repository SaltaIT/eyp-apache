# puppet2sitepp @apachebalancers
define apache::mod::proxy::balancer (
                                      $members,
                                      $balancername = $name,
                                      $ensure       = 'present',
                                      $lbmethod     = undef,
                                    ) {

  include ::apache::mod::proxybalancer

  validate_hash($members)

  file { "${apache::params::baseconf}/conf.d/balancers.conf":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Class[['apache', 'apache::version']], File["${apache::params::baseconf}/conf.d"] ],
    notify  => Class['::apache::service'],
    content => template("${module_name}/proxy/balancer.erb"),
  }

}
