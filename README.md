# apache

![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

**NTTCom-MS/eyp-apache**: [![Build Status](https://travis-ci.org/NTTCom-MS/eyp-apache.png?branch=master)](https://travis-ci.org/NTTCom-MS/eyp-apache)

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

requirements:

**eyp/eyplib** is required to be able to use helper functions like **bool2onoff**
**puppetlabs/concat**: most config files are created using concat (beaware of file changes)


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

## Usage

In this section we have several usage examples, most were used to test module's features or acceptance testing checks (**spec/acceptance/base\*_spec.rb**)

### general Options

#### aliasmatch, scriptalias, rewrites and directory directives

```puppet
apache::vhost {'testing.lol':
        order => '77',
        serveradmin => 'root@lolcathost.lol',
        serveralias => [ '1.testing.lol', '2.testing.lol' ],
        documentroot => '/var/www/testing/',
        options => [ 'Indexes', 'FollowSymLinks', 'MultiViews' ],
        rewrites => [
          'RewriteCond %{HTTP_HOST} !^testing\.lol',
          'RewriteRule ^/(.*)$ http://www\.testing\.lol/$1 [R=301,L]'
          ],
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

#### custom logformats

we can add custom log formats using **logformats** hash, for example:

```puppet
class { 'apache':
  server_admin=> 'webmaster@localhost',
  maxclients=> '150',
  maxrequestsperchild=>'1000',
  customlog_type=>'vhost_combined',
  logformats => {
      'vhost_combined' =>
        '%v:%p %h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"'
        },
  add_defult_logformats=>true,
}
```

#### Load custom module

```puppet
apache::module { 'asis_module':
  sofile => 'modules/mod_asis.so',
}
```

### server-status

#### server-status on a custom vhost with restricted IPs

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

### mod_php

```puppet
class { 'apache': }

apache::vhost {'default':
  defaultvh=>true,
  documentroot => '/var/www/void',
}

class { 'apache::mod::php': }
```

### SSL

#### SSL setup using yaml

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

#### SSL without intermediate certificate

If we don't have a intermediate certificate, we can disable it using **use_intermediate** (intended for testing only)

```puppet
apache::vhost {'et2blog_ssl':
  documentroot => '/var/www/et2blog',
  port => 443,
  certname => 'cert_et2blog_ssl',
  use_intermediate => false,
}
```

#### mod_nss

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

### Sorry page

every vhost created using this module have an alternative vhost to disable it (**HTTP 503**)

#### enable/disable sorry page

to enable or disable the sorry page for a given site we just need to flip **site_running**

```puppet
apache::vhost {'systemadmin.es':
  order        => '10',
  port         => '81',
  documentroot => '/var/www/systemadmin',
  site_running => false,
}
```

#### Custom sorry page

custom_sorrypage hash must contain both variables (**path** and **errordocument**)

```puppet
apache::vhost {'systemadmin.es':
  order        => '10',
  port         => '81',
  documentroot => '/var/www/systemadmin',
  custom_sorrypage => { 'path': '/var/www/systemadmin/maintenance',
                        'errordocument': 'maintenance.html',
  }
}

```

### mod_proxy

#### mod_proxy_balancer

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

#### Exclude healthcheck

```puppet
apache::vhost {'systemadmin.es':
  order        => '10',
  port         => '81',
  documentroot => '/var/www/systemadmin',
  custom_sorrypage => { 'path': '/var/www/systemadmin/maintenance',
                        'errordocument': 'maintenance.html',
                        'healthcheck': 'healthcheck/healthcheck.html',
  }
}
```

### FCGI

```puppet
class {'apache::fcgi':
  fcgihost => '192.168.56.18',
}
```

## Reference

### facts

* **eyp_apache_gcc**: get gcc version
* **eyp_apache_make**: get make version
* **eyp_apache_opensslver**: get openssl version

### global hiera settings

* **eypapache::monitips**: IP list to be allowed by default in the default vhost

### classes

#### apache

private classes:
* **apache::params**: apache default values
* **apache::service**: apache service
* **apache::version**: detect distro's apache version

#### apache::fcgi

installs mod_fastcgi

* **srcdir**: (default: /usr/local/src)
* **handler_name**: (default: resource's name)
* **fcgihost**: (default: 127.0.0.1)
* **fcgiport**: (default: 9000)

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
* **randomseed**: Array to configure a set of sources to seed the PRNG of the SSL library. (default: builtin)
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
* **documentroot**: DocumentRoot
* **order**: Order (default: 00)
* **port**: Listen port (default: 80)
* **use_intermediate**: (default: true)
* **certname_version**:
* **directoryindex**: (default: [ 'index.php', 'index.html', 'index.htm' ])
* **defaultvh**: Only for default virtual host (default: false)
* **defaultvh_ss**: Enable or disable default virtual host server status (default: true)
* **servername**: ServerName (default: $name)
* **serveralias**: ServerAlias (default: undef)
* **allowedip**: Allowed ip for DocumentRoot (default: undef)
* **deniedip**: Denied ip for DocumentRoot (default: undef)
* **rewrites**: Rewrites list (default: undef)
* **rewrites_source**:  (default: undef)
* **certname**:         (default: undef)
* **serveradmin**: ServerAdmin     (default: undef)
* **aliasmatch**: AliasMatch list      (default: undef)
* **scriptalias**: ScriptAlias list     (default: undef)
* **options**: Options for DocumentRoot directory (default: [ 'FollowSymlinks' ])     
* **allowoverride**: AllowOverride (default: None)
* **aliases**: Alias list (default: undef)
* **add_default_logs**: Add default logging (default: true)
* **site_running**: Define if site should be running (true) or sorrypage should be shown (false) (default: true)
* **custom_sorrypage**: Define a custom sorry page. A hash with 'path' (where sorrypage document is stored) and 'errordocument' (document to load as sorry page) must be provided. If the vhost is load balanced and needs to serve a healthcheck page we can exclude it from 503 adding it to the key 'healthcheck'. (see Usage documentation) (default: undef)

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
