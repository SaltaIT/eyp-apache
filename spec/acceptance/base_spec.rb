require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        server_admin=> 'webmaster@localhost',
        maxclients=> '150',
        maxrequestsperchild=>'1000',
        customlog_type=>'vhost_combined',
        logformats=>{ 'vhost_combined' => '%v:%p %h %l %u %t \\"%r\\" %>s %O \\"%{Referer}i\\" \\"%{User-Agent}i\\"' },
        add_defult_logformats=>true,
        manage_docker_service => true,
      }

      apache::vhost {'default':
        defaultvh=>true,
        documentroot => '/var/www/void',
      }

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
      }

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

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    it "apache configtest" do
      expect(shell("apachectl configtest").exit_code).to be_zero
    end

    it "sleep 10 to make sure apache is started" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    describe port(80) do
      it { should be_listening }
    end

    describe package($packagename) do
      it { is_expected.to be_installed }
    end

    describe service($servicename) do
      it { should be_enabled }
      it { is_expected.to be_running }
    end

    # general conf
    describe file($generalconf) do
      it { should be_file }
      its(:content) { should match 'MaxRequestsPerChild  1000' }
      its(:content) { should match 'MaxClients       150' }
      its(:content) { should match 'ServerLimit      150' }
      its(:content) { should match 'ServerAdmin webmaster@localhost' }
      its(:content) { should match 'access_log vhost_combined' }
      its(:content) { should match 'LogFormat "%{User-agent}i" agent' }
      #TODO: arreglar
      #its(:content) { should match /LogFormat "%v:%p %h %l %u %t \"%r\" %>s %O \"%{Referer}i\" \"%{User-Agent}i\"" vhost_combined/ }
    end

    #default vhost
    describe file($defaultsiteconf) do
      it { should be_file }
      its(:content) { should match 'DocumentRoot /var/www/void' }
    end

    #et2 vhost
    describe file($et2blogconf) do
      it { should be_file }
      its(:content) { should match 'DocumentRoot /var/www/et2blog' }
    end

    #testing vhost
    describe file($testingconf) do
      it { should be_file }
      #TODO: arreglar
      #its(:content) { should match /<VirtualHost *:80>/ }
      its(:content) { should match 'DocumentRoot /var/www/testing' }
      its(:content) { should match 'ServerName testing.lol' }
      its(:content) { should match 'ServerAlias 1.testing.lol' }
      its(:content) { should match 'ServerAlias 2.testing.lol' }
      its(:content) { should match 'ServerAdmin root@lolcathost.lol' }
      its(:content) { should match 'DirectoryIndex index.php lolindex.php lol.html' }
      its(:content) { should match 'Options Indexes FollowSymLinks MultiViews' }
      its(:content) { should match 'RewriteEngine On' }
      #TODO: arreglar
      #its(:content) { should match /RewriteCond %{HTTP_HOST} !^testing\.lol/ }
      #its(:content) { should match /RewriteRule ^\/(.*)$ http:\/\/www\.testing\.lol\/$1 [R=301,L]/ }
      its(:content) { should match 'AliasMatch RUC/lol /var/www/testing/hc.php' }
      its(:content) { should match 'AliasMatch (.*) /var/www/testing/cc.php' }
      its(:content) { should match 'ScriptAlias /cgi-bin/ "/var/www/testing/cgi-bin/"' }
      its(:content) { should match 'Directory /var/www/testing' }
      its(:content) { should match '</VirtualHost>' }
      its(:content) { should match '<Directory /var/www/testing/cgi-bin/>' }
      its(:content) { should match 'AllowOverride None' }
      #TODO: arreglar
      #its(:content) { should match /Options +ExecCGI -Includes/ }
      its(:content) { should match '</Directory>' }
    end

  end

end
