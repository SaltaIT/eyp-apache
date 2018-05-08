class { 'apache':
  listen                => [ '80', '443' ],
  ssl                   => true,
  manage_docker_service => true,
}

apache::vhost { 'default':
  defaultvh    => true,
  documentroot => '/var/www/void',
}

apache::vhost { 'et2blog':
  documentroot => '/var/www/et2blog',
}

apache::vhost { 'et2blog_ssl':
  documentroot     => '/var/www/et2blog',
  port             => 443,
  certname         => 'cert_et2blog_ssl',
  use_intermediate => false,
}

apache::vhost { 'et2blog_ssl_sorry':
  site_running     => false,
  documentroot     => '/var/www/et2blog',
  port             => 443,
  certname         => 'cert_et2blog_ssl',
  use_intermediate => false,
}

apache::cert { 'cert_et2blog_ssl':
  pk_file   => '/etc/pk',
  cert_file => '/etc/cert',
  require   => File[['/etc/cert','/etc/pk']],
}

file { '/var/www/et2blog/check.rspec':
  ensure  => 'present',
  content => "\nOK\n",
  require => Apache::Vhost[['et2blog','et2blog_ssl']],
}

file { '/etc/cert':
  ensure  => 'present',
  content => "-----BEGIN CERTIFICATE-----\nMIIDPDCCAiQCCQCKavwUiENvADANBgkqhkiG9w0BAQsFADBgMQswCQYDVQQGEwJD\nQTESMBAGA1UECAwJQmFyY2Vsb25hMRIwEAYDVQQHDAlCYXJjZWxvbmExFzAVBgNV\nBAoMDnN5c3RlbWFkbWluLmVzMRAwDgYDVQQDDAdldDJibG9nMB4XDTE2MDIyMzE0\nNTA0OFoXDTQzMDcxMTE0NTA0OFowYDELMAkGA1UEBhMCQ0ExEjAQBgNVBAgMCUJh\ncmNlbG9uYTESMBAGA1UEBwwJQmFyY2Vsb25hMRcwFQYDVQQKDA5zeXN0ZW1hZG1p\nbi5lczEQMA4GA1UEAwwHZXQyYmxvZzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCC\nAQoCggEBAM80rpsjhS6H/zH7UaX0ByJMIDKC82a5cz+1R+ylVsqagmE5TuJkF9gx\nj8tNBRz+Pj3Ef/GbPNaDAICAm6eT5xOI4q789R6ONnE5IZkKghtQFzllWDDlT6Yz\n8YSFgeFLNZhIbd6/xzmSrigwK6VpX3J2Bdf5Kzu4dV0xgygxvlYaM87lNmKUfXa+\nYzTM/XyvsIV7Y5PSF9E5TgtKiUu4tdBscWXB/SR59WLAGBGK7lh/3Q0bZZ6aiXn3\n9atVIG0pX6+nOiwcfUwZU3iu1jZBT3AzR6a9HtWd4Kas9pbygWA4Rg/CMeebp9o/\n4SzbMQsGFs26KSgkXIO8QI3tvC1qRqkCAwEAATANBgkqhkiG9w0BAQsFAAOCAQEA\nS+97Qm+rr9/hKo+uEDGUwrMOVE4ArOaacD65De5+7sk5Fj0qAz/RCYRnRFPf5j7j\ns1vaaslohxwwHIaP6oMCMLAFU1kpj3Nn12uPpqinLxJCUBSToCtA7vvg+TXYYcIV\n++rZJEaWZY4OIOaBn3q6vUvyaSQM2npN/xGe4StfOPTR72YkiXTGJqlJU/qxyKxz\nAoW4ov3rHBbRq4O0pxuGdlRloInLzV8echzTvefoMU/PI8jEKj6q76Bt5GsAL5ND\nfAuNWh6XaJSYTFzrycusCQ1cYlvYPZCCZIPLYaTbzBdfbj0Qe3EhYzeh3Q36DIYc\nBAZtMTRqjKRr7bBdyR1wHQ==\n-----END CERTIFICATE-----\n",
  before  => Apache::Vhost[['et2blog_ssl', 'et2blog_ssl_sorry']],
}

file { '/etc/pk':
  ensure  => 'present',
  content => "-----BEGIN RSA PRIVATE KEY-----\nMIIEpQIBAAKCAQEAzzSumyOFLof/MftRpfQHIkwgMoLzZrlzP7VH7KVWypqCYTlO\n4mQX2DGPy00FHP4+PcR/8Zs81oMAgICbp5PnE4jirvz1Ho42cTkhmQqCG1AXOWVY\nMOVPpjPxhIWB4Us1mEht3r/HOZKuKDArpWlfcnYF1/krO7h1XTGDKDG+VhozzuU2\nYpR9dr5jNMz9fK+whXtjk9IX0TlOC0qJS7i10GxxZcH9JHn1YsAYEYruWH/dDRtl\nnpqJeff1q1UgbSlfr6c6LBx9TBlTeK7WNkFPcDNHpr0e1Z3gpqz2lvKBYDhGD8Ix\n55un2j/hLNsxCwYWzbopKCRcg7xAje28LWpGqQIDAQABAoIBAHrhkVMr44XO3Ub0\n9lzmtXxfjRCnnFWlUXXMulTbUPdiXkPuSpv0JDfwXIiCqq+hD6Rt7jqIh7Hnitqq\naqUdD4MEQPrpxSxTxnGrIgOyuaoc+0jskzqcI3o7f9XJn1bO1X/0JERfk3TPSj1H\nI/s63IHzAFAu0rbeE6wq+s9RgMFqQ3Zg0VQn5t57AdtCuw72rQAz5QpXIcOxDnSh\nepyoOdipOhevbFJ1ZNyLG6MMOr7t5lrv8wyRgWYJrJzNjLd7N+DaqVToVDimn1+2\ncccgF6shkaS8Mc0nsoySqbqmAFjfMjLDmCXTRMNauzx/NhV738OIW59NDzJhY/Mk\nOY4sx+kCgYEA5rnpyim1NIQw7wIeyyILLV1a4yyfHxvmEXFin3WCTaA+aUS3aPyi\n9GHux6IYcTSVD0G+/aRVDTOvURWlA7oRLH+GGwnE+698u65+m8Pd90ZRaHoCPDVR\nIhfp87ePS2XTIXxVWbNHjXL2U4+Llm2ahbLjO7LBXX0ciH62IxVqYGcCgYEA5ecz\n1V3KEaSKQ4HPQo84PWW/HXgFPud/Wovqhtm2DfhvkJZGc7yLOLAXQD5+2M6Mg05b\nHYEtYNL0xr2JX0Ih6bt2KxXXqd0Jnctw6dP6XBuKmwof19rEVcYsr9GEhR5ZNr4K\n7u616Yn59IfckcVcxyjUOCri4YVgCUiWI7Btdm8CgYEAoDEobyJyG1pEl01DkAm8\n9OxCNERA3lqCbE3rCYeOxtKhQnlhVlVB1qdAH/8dNUwqygL91iEIpDfkW0nJ3kKL\ntfd8Zr1rtMtssOpAIWnmbM63qvA7KQ5jnGY6GuqxZMn3wuIOaE8fOMg+2llpszG5\n/WXsewBrXLuG2gYP81/lEbUCgYEAgS6FwJl/xqQXENGq/TJunolCdzOOdwcrV1yR\nPo6srnLvdWYLVlMWQ5cmqXG0YuzEpa9soUqJjgNbiSTNQNpvJd+xCYqvcQIDuker\nPahf4EuVeYKZ2/dQJQZC69Qly4r/BDSK/jDhxMVDzzRcKwikFkCJ5rmqXKBOE0lX\nG9yx1T8CgYEApqteiivtjqyzNl68OjJkdz4dQd32qDADphd6nVkvLBal9QlLH7tP\nFuE9sC1C7x4/dDzjy0zKJG1Cs6Ua7nnoZ+T149Q5DRRbCs2Csy8GaIsPc5oTjFx3\n6YoHI2TZzcP7Wk+hF1mKxqntXHZTYOtx0WtoZ6b6qlj+Obvy7UzJD4g=\n-----END RSA PRIVATE KEY-----\n",
  before  => Apache::Vhost[['et2blog_ssl', 'et2blog_ssl_sorry']],
}
