define apache::mod::proxy::balancer (
                                      $members,
                                      $balancername = $name,
                                      $ensure       = 'present',
                                    ) {

  if ! defined(Class['apache::mod::proxybalancer'])
  {
    fail('You must include the apache::mod::proxybalancer class before using any resources')
  }

  validate_hash($members)

  file { "${apache::params::baseconf}/conf.d/balancers.conf":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Class[['apache', 'apache::version']], File["${apache::params::baseconf}/conf.d"] ],
    content => template("${module_name}/proxy/balancer.erb"),
  }

}
