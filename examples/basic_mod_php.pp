class { 'apache':
  listen                => [ '80' ],
  manage_docker_service => true,
}

class { 'apache::mod::php': }
