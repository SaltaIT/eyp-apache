class { 'apache':
  server_admin          => 'webmaster@localhost',
  maxclients            => '150',
  maxrequestsperchild   => '1000',
  customlog_type        => 'vhost_combined',
  logformats            => { 'vhost_combined' => '%v:%p %h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"' },
  add_defult_logformats => true,
  manage_docker_service => true,
}

apache::vhost {'default':
  defaultvh    => true,
  documentroot => '/var/www/void',
}

apache::vhost {'et2blog':
  documentroot => '/var/www/et2blog',
}

# AuthName "AD authentication"
# AuthBasicProvider ldap
# AuthType Basic
# AuthLDAPGroupAttribute member
# AuthLDAPGroupAttributeIsDN On
# AuthLDAPURL "ldaps://srv-ad02.nttcom.ms.local/OU=NTTCMS,DC=nttcom,DC=ms,DC=local?sAMAccountName?sub?(objectClass=user)"
# AuthLDAPBindDN  "cn=auth GBM,OU=Service Account,OU=NTTCMS,DC=nttcom,DC=ms,DC=local"
# AuthLDAPBindPassword "XXXXXXXX"
# AuthUserFile /dev/null
# Require valid-user
apache::vhost::adsauth { 'et2blog':
  url => '/',
  auth_ldap_url => 'ldaps://srv-ad02.nttcom.ms.local/OU=NTTCMS,DC=nttcom,DC=ms,DC=local?sAMAccountName?sub?(objectClass=user)',
  auth_ldap_bind_dn => 'cn=auth GBM,OU=Service Account,OU=NTTCMS,DC=nttcom,DC=ms,DC=local',
  auth_ldap_bind_password => 'XXXXXXXX',
}

apache::vhost {'testing.lol':
        order                  => '77',
        serveradmin            => 'root@lolcathost.lol',
        serveralias            => [ '1.testing.lol', '2.testing.lol' ],
        documentroot           => '/var/www/testing/',
        options                => [ 'Indexes', 'FollowSymLinks', 'MultiViews' ],
        rewrites               => [ 'RewriteCond %{HTTP_HOST} !^testing\.lol', 'RewriteRule ^/(.*)$ http://www\.testing\.lol/$1 [R=301,L]' ],
        aliasmatch             => { 'RUC/lol' => '/var/www/testing/hc.php',
                                  '(.*)' => '/var/www/testing/cc.php'},
        scriptalias            => { '/cgi-bin/' => '"/var/www/testing/cgi-bin/"' },
        directoryindex         => [ 'index.php', 'lolindex.php', 'lol.html' ],
}

apache::directory { 'testing.lol':
                      directory     => '/var/www/testing/cgi-bin/',
                      vhost_order   => '77',
                      options       => [ '+ExecCGI', '-Includes' ],
                      allowoverride => 'None',
}
