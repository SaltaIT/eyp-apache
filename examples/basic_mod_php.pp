class { 'apache':
  listen                => [ '80' ],
  manage_docker_service => true,
}

class { 'apache::mod::php': }

apache::vhost { 'default':
  defaultvh    => true,
  documentroot => '/var/www/void',
}
