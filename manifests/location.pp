#
# LoadModule auth_kerb_module modules/mod_auth_kerb.so
#
# <Location /secured>
# AuthType Kerberos
# AuthName “Kerberos Login”
# KrbMethodNegotiate On
# KrbMethodK5Passwd On
# KrbAuthRealms EXAMPLE.COM
# Krb5KeyTab /etc/httpd/conf/httpd.keytab
# require valid-user
# </Location>
#
define apache::location() {

}
