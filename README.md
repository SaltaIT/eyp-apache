# apache

**NTTCom-MS/eyp-apache**: [![Build Status](https://travis-ci.org/NTTCom-MS/eyp-apache.png?branch=master)](https://travis-ci.org/NTTCom-MS/eyp-apache)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description](#module-description)
3. [Setup](#setup)
    * [What apache affects](#what-apache-affects)
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

apache::directory {'testing.lol':
                      vhost_order      => '77',
                      directory       => '/var/www/testing/cgi-bin/',
                      options          => [ '+ExecCGI', '-Includes' ],
                      allowoverride    => 'None',
}
```

#### redirect

```puppet
apache::vhost {'et2blog':
  documentroot => '/var/www/et2blog',
}

apache::redirect { 'et2blog':
  path => '/',
  url => 'http://systemadmin.es/',
}
```

#### proxypass

```puppet
class { 'apache::mod::proxy': }
class { 'apache::mod::proxyajp': }
class { 'apache::mod::proxybalancer': }

apache::mod::proxy::balancer { 'test':
  members =>  { 'ajp://app1.example.com:8009' => undef,
                'ajp://app2.example.com:8009' => undef,
              }
}

apache::mod::proxy::proxypass { '/lol':
  destination => 'balancer://test',
  servername => 'et2blog',

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

### addtype

```puppet
apache::addtype { '.sinep':
  mediatype => 'application/sinep',
}
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

#### HSTS

```puppet
apache::vhost {'et2blog':
  documentroot            => '/var/www/et2blog',
  hsts                    => true,
  hsts_include_subdomains => true,
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

#### includes

```puppet
apache::include_conf { '/etc:
  files => [ 'demo.conf' ],
}
```

### mod_headers

#### apache::header

```puppet2
apache::vhost {'et2blog':
  documentroot => '/var/www/et2blog',
}

apache::header { 'et2blog':
  header_name => 'X-Joke',
  header_value => 'no hay MAC que por ARP no venga',
  condition => 'always',
}
```

this adds the following directive:

```
Header onsuccess set X-Joke "no hay MAC que por ARP no venga"
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

* **eypapache::monitips**: IP list to be allowed by default in the default vhost. Used in **apache::serverstatus** as a default list of allowd IPs
* **eypapache::pfs**: enable Perfect Fordward Secrecy (PFS) - it changed default ciphers to use ECC

### classes

#### apache

private classes:
  * **apache::params**: apache default values
  * **apache::service**: apache service
  * **apache::version**: detect distro's apache version

apache variables:
* operational variables:
  * **manage_service**        = true,
  * **manage_docker_service** = false,
  * **purge_logrotate**: Purge package's related logrotate configuration (default: true)
  * **compress_logs_mtime**: compress log files after this value (for example: +3, default: undef)
  * **delete_logs_mtime**: delete log files after this value (for example: +3, default: undef)
* distro related variables:
  * **version**               = $apache::version::default,
  * **apache_username**       = $apache::params::apache_username,
  * **apache_group**          = $apache::params::apache_group,
  * **logdir**                = $apache::params::logdir,
* general options:
  * **mpm**                   = $apache::params::mpm_default,
  * **servertokens**          = $apache::params::servertokens_default,
  * **timeout**               = $apache::params::timeout_default,
  * **keepalive**             = $apache::params::keepalive_default,
  * **keepalivetimeout**      = $apache::params::keepalivetimeout_default,
  * **maxkeepalivereq**       = $apache::params::maxkeepalivereq_default,
  * **extendedstatus**        = $apache::params::extendedstatus_default,
  * **serversignature**       = $apache::params::serversignature_default,
  * **listen**                = [ '80' ],
  * **namevirtualhosts**      = undef,
  * **ssl**                   = false,
  * **sni**                   = true,
  * **trace**                 = false,
  * **server_admin**          = $apache::params::server_admin_default,
  * **directoty_index**       = [ 'index.html' ],
  * **maxclients**            = $apache::params::maxclients_default,
  * **maxrequestsperchild**   = $apache::params::maxrequestsperchild_default,
  * **customlog_type**        = $apache::params::customlog_type_default,
  * **logformats**            = undef,
  * **add_defult_logformats** = true,
  * **server_name**           = $apache::params::server_name_default,
  * **ssl_compression**       = $apache::params::ssl_compression_default,
  * **ssl_protocol**          = $apache::params::ssl_protocol_default,
  * **ssl_chiphersuite**      = $apache::params::ssl_chiphersuite_default,
  * **defaultcharset**        = 'UTF-8',
  * **loglevel_errorlog**     = 'warn',
  * **usecanonicalname**      = false,
  * **default_documentroot**  = '/var/www/html',
  * **accessfilename**        = '.htaccess',
  * **hostnamelookups**       = false,
  * **startservers**          = 8,
  * **minspareservers**       = 5,
  * **maxspareservers**       = 20,


#### apache::fcgi

installs mod_fastcgi

* **srcdir**: (default: /usr/local/src)
* **handler_name**: (default: resource's name)
* **fcgihost**: (default: 127.0.0.1)
* **fcgiport**: (default: 9000)

#### modules

##### apache::mod::deflate

* **ensure**: installed/purged (default: installed)

##### apache::mod::expires

* **ensure**: installed/purged (default: installed)
* **expires_active**: true/false (default: true)
* **default_expire**: default expire policy (default: access plus 1 year)

##### apache::mod::php

**WARNING** Only works on Ubuntu 14.04

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

* **pk_source**: private key certificate source, incompatible with **pk_file**
* **pk_file**: private key certificate file path, file is already present on the fs. incompatible with **pk_source** - intended for testing only
* **cert_source**: cert certificate source, incompatible with **cert_file**
* **cert_file**: cert certificate file path, file is already present on the fs. incompatible with **cert_source** - intended for testing only
* **intermediate_source**: intermediate certificate source
* **certname**: cert name (default: resource's name)
* **version**: optional, cert version (to be able to keep several versions)

#### apache::custom_conf

* **source**: file to deploy
* **filename**: file to be deployed (default: resource's name)

file will be deployed in this path: **${apache::params::baseconf}/conf.d/${filename}.conf**

#### apache::directory

* **order**: order of the vhost where we want to deploy the directory (default: 00)
* **port**: port of the vhost where we want to deploy the directory (default: 80)
* **servername**: servername on which we want to deploy the directory (default: resource's name)
* **directory**: directory to define (mandatory)
* **allowedip**: allow a given set of IPs to this directory (default: undef)
* **denyip**: deny a given set of IPs to this directory (default: undef)
* **options**: directory options (default: [ 'FollowSymlinks' ])
* **allowoverride**: allow override (default: None)

#### apache::module

* **sofile**: file to load
* **modname**: module name (default: resource's name)
* **order**: just in case it's relevant

#### apache::serverstatus

* **order**: order of the vhost where we want to deploy the server-status (default: 00)
* **port**: port of the vhost where we want to deploy the server-status (default: 80)
* **serverstatus_url**: server-status URL (default: **/server-status**)
* **servername**: servername on which we want to deploy the server-status
* **allowedip**: (default: **eypapache::monitips**)
* **defaultvh**: Defines whether this server-status is intended to be used in the default vhost or not (default: false)

#### apache::redirect

* **url**: destinarion URL
* **path**: path to redirect,
* **status**: redirect type (default: permanent)
* **match**: whether use RedirectMatch or nor (default: undef)
* **order**: order of the vhost where we want to deploy the redirect (default: 00)
* **port**: port of the vhost where we want to deploy the redirect (default: 80)
* **servername**: servername on which we want to deploy the redirect

example:

```puppet
apache::redirect { 'et2blog':
  path => '/',
  url => 'http://systemadmin.es/',
}
```

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
* **serveralias**: ServerAlias array (default: undef)
* **allowedip**: Allowed ip for DocumentRoot (default: undef)
* **deniedip**: Denied ip for DocumentRoot (default: undef)
* **rewrites**: Rewrites list (default: undef)
* **rewrites_source**:  (default: undef)
* **certname**:         (default: undef)
* **serveradmin**: ServerAdmin (default: undef)
* **aliasmatch**: AliasMatch hash (default: undef)
* **scriptalias**: ScriptAlias hash (default: undef)
* **options**: Options for DocumentRoot directory (default: [ 'FollowSymlinks' ])     
* **allowoverride**: AllowOverride (default: None)
* **aliases**: Alias hash (default: undef)
* **add_default_logs**: Add default logging (default: true)
* **site_running**: Define if site should be running (true) or sorrypage should be shown (false) (default: true)
* **custom_sorrypage**: Define a custom sorry page. A hash with 'path' (where sorrypage document is stored) and 'errordocument' (document to load as sorry page) must be provided. If the vhost is load balanced and needs to serve a healthcheck page we can exclude it from 503 adding it to the key 'healthcheck'. (see Usage documentation) (default: undef)
* **documentroot_owner**: documentroot's owner (default: root)
* **documentroot_group**: documentroot's owner (default: group)
* **documentroot_mode**: documentroot's mode (default: 0755)

## Limitations

Tested on:
* CentOS 6
* CentOS 7
* Ubuntu 16.04
* Ubuntu 18.04

## Development

We are pushing to have acceptance testing in place, so any new feature should
have some test to check both presence and absence of any feature

### Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
