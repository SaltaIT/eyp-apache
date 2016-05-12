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

mod_proxy_balancer:

```yaml
classes:
  - apache
  - apache::mod::expires
  - apache::mod::proxy
  - apache::mod::proxybalancer
  - apache::mod::proxyajp
apache::listen:
  - 7790
apachevhosts:
  default:
    defaultvh: true
    documentroot: /var/www/void
    port: 7790
  pspstores.systemadmin.es:
    documentroot: /var/www/void
    port: 7790
apachebalancers:
  pspstores:
    members:
      'ajp://192.168.56.19:9509': undef
      'ajp://192.168.56.18:9509': undef
apacheproxypasses:
  '/':
    destination: 'balancer://pspstores'
    servername: pspstores.systemadmin.es
    port: 7790
  '/manager':
    destination: '!'
    servername: pspstores.systemadmin.es
    port: 7790
  '/host-manager':
    destination: '!'
    servername: pspstores.systemadmin.es
    port: 7790
```

mod_nss usage:

```puppet
# vhost for ZnVja3RoYXRiaXRjaAo.com

apache::vhost {'ZnVja3RoYXRiaXRjaAo.com':
  port         => '443',
  documentroot => '/var/www/void',
}

# generate CSR

apache::nss::csr { 'test2':
  cn => 'ZnVja3RoYXRiaXRjaAo.com',
  organization => 'systemadmin.es',
  organization_unit => 'shitty apache modules team',
  locality => 'barcelona',
  state => 'barcelona',
  country => 'RC', # Republica Catalana
}

# import intermediate

apache::nss::intermediate { 'intermediate':
  intermediate_source => 'puppet:///certs/intermediate.crt',
}

# import actual certificate

apache::nss::cert { 'ZnVja3RoYXRiaXRjaAo':
  intermediate_source => 'puppet:///certs/cert.crt',
}

# enable mod_nss for this vhost

apache::nss {'ZnVja3RoYXRiaXRjaAo.com':
  port      => '443',
}
```


## Usage

TODO

## Reference

### facts

* **eyp_apache_gcc**: get gcc version
* **eyp_apache_make**: get make version
* **eyp_apache_opensslver**: get openssl version

### functions

* **bool2httpd**: bool to On/Off, pass all other values through

### global hiera settings

* **eypapache::monitips**: IP list to be allowed by default in the default vhost

### classes

#### apache

private classes:
* **apache::params**: apache default values
* **apache::service**: apache service
* **apache::version**: detect distro's apache version

#### apache::fcgi

#### apache::serverstatus

#### apache modules

##### apache::mod::deflate

* **ensure**: installed/purged (default: installed)

##### apache::mod::expires

* **ensure**: installed/purged (default: installed)
* **expires_active**: true/false (default: true)
* **default_expire**: default expire policy (default: access plus 1 year)

##### apache::mod::php

* **ensure**: installed/purged (default: installed)

##### apache::mod::proxy

* **ensure**: installed/purged (default: installed)

##### apache::mod::proxyajp

* **ensure**: installed/purged (default: installed)

##### apache::mod::proxybalancer

* **ensure**: installed/purged (default: installed)

##### apache::mod::proxyconnect

* **ensure**: installed/purged (default: installed)

##### apache::mod::proxyftp

* **ensure**: installed/purged (default: installed)

##### apache::mod::proxyhttp

* **ensure**: installed/purged (default: installed)

##### apache::mod::nss

* **ensure**: installed/purged (default: installed)
* **randomseed**: Configure a source to seed the PRNG of the SSL library. (default: builtin)
```
NSSRandomSeed startup builtin
NSSRandomSeed startup file:/dev/random  512
NSSRandomSeed startup file:/dev/urandom 512
```


### defines

#### apache::cert

#### apache::custom_conf

#### apache::directory

#### apache::module

#### apache::redirect

#### apache::vhost

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
