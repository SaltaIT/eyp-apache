# CHANGELOG

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
