# CHANGELOG

## 0.6.7

* updated **eyp-auditd** max version

## 0.6.6

* added CentOS 7 support for mod_php (via **apache::mod::php**)
* Explicitly disable SSLCompression by default

## 0.6.5

* updated metadata to allow **eyp-php:0.6**

## 0.6.4

* added CentOS 6 support for mod_php (via **apache::mod::php**)

## 0.6.3 - 2018-09-19

* fix dependencies

## 0.6.2 - 2018-06-19

* bugfix mod_php on Ubuntu 14.04

## 0.6.1

* added ssl certs to sorrypage
* added Ubuntu 18.04 support

## 0.6.0

* **INCOMPATIBLE CHANGES**:
  - disabled apache modules:
    - mod_userdir
    - mod_info
  - apache user shell under management by default
  - changed default **LogLevel** from **warn** to **notice core:info** for Apache 2.4 and **warn** for Apache 2.2
  - apache config cleanup (some useless directives have been removed)
* bugfix: default vhost documentroot ownership
* configurable **conf.d** purge/recurse
* added **apache::vhost::xframeoptions** to be able to easily add the X-Frame-Options header to a vhost
* added support for **mod_reqtimeout** using **apache::mod::reqtimeout**
* added variables for:
  - LimitRequestLine
  - LimitRequestFields
  - LimitRequestFieldSize
  - LimitRequestBody
* added block options to **apache::location** to be able to disable a specific URL
* added a flag to disable **mod_autoindex**
* added flag to **disable FollowSymlinks** by default
* added **limit_http_methods** variable to **apache::location** to be able to limit http methods by URL
* added **disablereuse** variable to **apache::proxy::proxypass**
* added AD auth support:
  - mod_ldap via **apache::mod::ldap**
  - AD auth via **apache::vhost::adsauth**

## 0.5.13

* added audit rules for apache config files

## 0.5.12

* fixed hard-coded **SSLSessionCache**

## 0.5.11

* added timeout and connectiontimeout variables to **apache::mod::proxy::proxypass**
* removed checks for subclasses, auto include required classes

## 0.5.10

* added variable **root_directory_deny** to set allow or deny by default to /

## 0.5.9

* added **AllowEncodedSlashes** to **apache::vhost**

## 0.5.8

* added **apache::alias**
* added selinux_httpd_use_nfs flag to allow httpd to use NFS mounts

## 0.5.7

* added listen_address to **apache::vhost**
* modified **apache::mod::proxy::balancer** to notify apache service

## 0.5.6

* added default **SSLStaplingCache**

## 0.5.5

* added **lbmethod** to **apache::mod::proxy::balancer**
* **INCOMPATIBLE CHANGE**: **apache::mod::proxy::proxypass** changed resource's name from **$url** to **$servername**, thus **url** is now a mandatory parameter

## 0.5.4

* bugfix apache 2.4 - prefork parameters were not being honored

## 0.5.3

* bugfix **apache::logformat**

## 0.5.2

* bugfix **apache::header**

## 0.5.1

* added **ssl_use_stapling** variable (only available on apache 2.4)
* added **apache::sslproxy**
* added **apache::location**
* added ssl_options to **apache::directory**
* added **apache::browsermatch**
* added description variable to **apache::vhost**
* added **apache::requestheader**
* added variables to **apache::mod::proxy**:
  * proxy_requests
  * proxy_via
  * proxy_preserve_host
* added **apache::mod::proxy::proxypassreverse**
* added ssl verify options:
  * SSLVerifyClient
  * SSLVerifyDepth
* added **customlog_filter** to **apache::vhost** to be able to filter logs
* added **apache::files** and **apache::filesmatch**
* added **apache::logformat**
* added log related variables to **apache::vhost**:
  * log_format
  * log_rotate_seconds
* **INCOMPATIBLE CHANGE**: changed default values for **apache::directory**, directory is now mandatory, servername now default's to resource's name
* bugfix: added unimplemented vhost options to the default vhost

## 0.4.26

* added **apache::addtype**

## 0.4.25

* added variable to be able to set **startservers**, **minspareservers**, **maxspareservers**
* added **apache::include_conf**
* **apache::vhost::includes** and **apache::vhost::includes_optional** to be able to include non puppet managed files to a vhost
* added option for **SSLHonorCipherOrder**
* added **HSTS** support: **apache::hsts** (using **mod_headers**)
* added a global variable to enable **PFS**

## 0.4.24

* apache cert links will notify **apache::service** (which by the way sets an implicit order)
* limit puppetlabs-concat to < 3.0.0

## 0.4.23

* added variable to be able to set umask for httpd

## 0.4.22

* added Ubuntu 16.04 support

## 0.4.21

* added to **apache::vhost**:
  * documentroot_owner
  * documentroot_group
  * documentroot_mode
* bugfix ServerAdmin in vhost template


## 0.4.20

* bugfix to be able to disable authentication on **apache::davsvnrepo**

## 0.4.19

* bugfix **url_cleanup** in **apache::davsvnrepo**

## 0.4.18

* added **proxytimeout** to **modproxy**

## 0.4.17

* added **defaultcharset** to **apache::vhost**

## 0.4.16

* added mod_headers support

## 0.4.15

* changed hiera to hiera_array to merge arrays

## 0.4.14

* typo svnpath
* bugfix fragment vhost
* bugfix template **davsvnrepo.erb**

## 0.4.9

* added **apache::davsvnrepo** with kerberos auth

## 0.4.8

* bugfix centos 6: /etc/httpd/modules/mod_authn_core.so

## 0.4.7

* added kerberos auth support

## 0.4.6

* minor bugfix

## 0.4.5

* mod_proxy (ProxyStatus changed default to **On**)

## 0.4

* **INCOMPATIBLE CHANGE**: Changed general ErrorLog and CustomLog to use rotatelogs, deleting any related logrotate stuff

## 0.3

* modules not loaded anymore by default:
  * proxy
  * proxy_ajp
  * proxy_balancer
  * proxy_connect
  * proxy_ftp
  * proxy_http
