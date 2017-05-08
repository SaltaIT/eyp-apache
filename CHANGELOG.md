# CHANGELOG

## 0.4.25

* added variable to be able to set startservers, minspareservers, maxspareservers
* added **apache::include_conf**
* **apache::vhost::includes** and **apache::vhost::includes_optional** to be able to include non puppet managed files to a vhost
* added option for **SSLHonorCipherOrder**
* added preliminar **HSTS** support: **apache::hsts** (using **mod_headers**)

## 0.4.24

* apache cert links will notify apache::service (which by the way sets an implicit order)
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

### Incompatible changes

* Changed general ErrorLog and CustomLog to use rotatelogs, deleting any related logrotate stuff

## 0.3

* modules not loaded anymore by default:
  * proxy
  * proxy_ajp
  * proxy_balancer
  * proxy_connect
  * proxy_ftp
  * proxy_http
