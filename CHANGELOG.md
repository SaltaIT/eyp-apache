# CHANGELOG

## 0.3

* modules not loaded anymore by default:
  * proxy
  * proxy_ajp
  * proxy_balancer
  * proxy_connect
  * proxy_ftp
  * proxy_http

## 0.4

### Incompatible changes

* Changed general ErrorLog and CustomLog to use rotatelogs, deleting any related logrotate stuff
