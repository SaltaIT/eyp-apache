# apache

![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

**AtlasIT-AM/eyp-apache**: [![Build Status](https://travis-ci.org/AtlasIT-AM/eyp-apache.png?branch=master)](https://travis-ci.org/AtlasIT-AM/eyp-apache)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What apache affects](#what-apache-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with apache](#beginning-with-apache)
4. [Usage](#usage)
5. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)
    * [Contributing](#contributing)

## Overview

Apache httpd setup

## Module Description

apache httpd and apache modules management

## Setup

### What apache affects

* installs httpd package
* optionally, manages httpd service
* puppet managed directories (purges unmanaged files):
  * ${apache_confdir}/conf.d
  * ${apache_confdir}/conf.d/sites
  * ${apache_confdir}/ssl

### Setup Requirements

This module requires pluginsync enabled

### Beginning with apache

Basic setup:

```puppet
class { 'apache': }

apache::vhost {'default':
  defaultvh=>true,
  documentroot => '/var/www/void',
}

apache::vhost {'et2blog':
  documentroot => '/var/www/et2blog',
}
```

server-status on a custom vhost with restricted IPs:

```puppet
apache::vhost {'default':
  defaultvh => true,
  documentroot => '/var/www/void',
}

apache::vhost {'et2blog':
  documentroot => '/var/www/et2blog',
}

apache::serverstatus {'et2blog':}

apache::vhost {'systemadmin.es':
  order        => '10',
  port         => '81',
  documentroot => '/var/www/systemadmin',
}

apache::serverstatus {'systemadmin.es':
  order     => '10',
  port      => '81',
  allowedip => ['1.1.1.1','2.2.2.2','4.4.4.4 5.5.5.5','127.','::1'],
}
```

SSL setup using yaml:

```yaml
classes:
  - apache
apache::listen:
  - 80
  - 443
apache::ssl: true
apachecerts:
  systemadmin:
    cert_source: puppet:///customers/systemadmin/star_systemadmin_net.crt
    pk_source: puppet:///customers/systemadmin/star_systemadmin_net.key
    intermediate_source: puppet:///customers/systemadmin/star_systemadmin_net.intermediate
apachevhosts:
  systemadmin:
    documentroot: /var/www/systemadmin
  systemadmin_ssl:
    documentroot: /var/www/systemadmin
    port: 443
    certname: systemadmin
```

FCGI:

```puppet
class {'apache::fcgi':
  fcgihost => '192.168.56.18',
}
```

Load custom module:

```puppet
apache::module { 'asis_module':
  sofile => 'modules/mod_asis.so',
}
```

mod_php:

```puppet
class { 'apache': }

apache::vhost {'default':
  defaultvh=>true,
  documentroot => '/var/www/void',
}

class { 'apache::mod::php': }
```

logformats example:

```puppet
class { 'apache':
  server_admin=> 'webmaster@localhost',
  maxclients=> '150',
  maxrequestsperchild=>'1000',
  customlog_type=>'vhost_combined',
  logformats=>{ 'vhost_combined' => '%v:%p %h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"' },
  add_defult_logformats=>true,
}

```

aliasmatch, scriptalias, rewrites and directory example:

```puppet
apache::vhost {'testing.lol':
        order => '77',
        serveradmin => 'root@lolcathost.lol',
        serveralias => [ '1.testing.lol', '2.testing.lol' ],
        documentroot => '/var/www/testing/',
        options => [ 'Indexes', 'FollowSymLinks', 'MultiViews' ],
        rewrites => [ 'RewriteCond %{HTTP_HOST} !^testing\.lol', 'RewriteRule ^/(.*)$ http://www\.testing\.lol/$1 [R=301,L]' ],
        aliasmatch => { 'RUC/lol' => '/var/www/testing/hc.php',
                        '(.*)' => '/var/www/testing/cc.php'},
        scriptalias => { '/cgi-bin/' => '"/var/www/testing/cgi-bin/"' },
        directoryindex => [ 'index.php', 'lolindex.php', 'lol.html' ],
}

apache::directory {'/var/www/testing/cgi-bin/':
                      vhost_order      => '77',
                      servername       => 'testing.lol',
                      options          => [ '+ExecCGI', '-Includes' ],
                      allowoverride    => 'None',
}
```

## Usage

TODO

## Reference

TODO

## Limitations

Tested on:
* CentOS 5
* CentOS 6
* Ubuntu 14.04

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
