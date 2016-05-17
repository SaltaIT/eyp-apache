require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context 'basic SSL setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        listen => [ '80', '443' ],
        ssl => false,
        manage_docker_service => true,
      }

      class { 'apache::mod::nss':
       certdbpassword => '123lestresbesones',
      }

      apache::vhost {'default':
        defaultvh=>true,
        documentroot => '/var/www/void',
      }

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
      }

      file { '/var/www/et2blog/check.rspec':
        ensure => 'present',
        content => "\nOK\n",
        require => Apache::Vhost[['et2blog','ssl ZnVja3RoYXRiaXRjaAo.com']],
      }

      apache::nss::cert { 'ZnVja3RoYXRiaXRjaAo':
    		aliasname => 'ZnVja3RoYXRiaXRjaAo',
    		selfsigned => true,
    		cn => 'www.ZnVja3RoYXRiaXRjaAo.com',
    		organization => 'systemadmin.es',
    		organization_unit => 'shitty apache modules team',
    		locality => 'barcelona',
    		state => 'barcelona',
    		country => 'RC', # Republica Catalana
    	}

    	apache::vhost {'ssl ZnVja3RoYXRiaXRjaAo.com':
    		servername => 'ZnVja3RoYXRiaXRjaAo.com',
    		order        => '11',
    		port         => '443',
    		documentroot => '/var/www/et2blog',
    	}

    	apache::nss {'ZnVja3RoYXRiaXRjaAo':
    		servername => 'ZnVja3RoYXRiaXRjaAo.com',
    		vhost_order     => '11',
    		port      => '443',
    		enforce_validcerts => false,
    	}

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    it "apache configtest" do
      expect(shell("apachectl configtest").exit_code).to be_zero
    end

    it "apache configtest mod_nss" do
      expect(shell("apachectl -M 2>&1 | grep nss_module").exit_code).to be_zero
    end

    it "sleep 60 to make sure apache is started" do
      expect(shell("sleep 60").exit_code).to be_zero
    end

    describe port(80) do
      it { should be_listening }
    end

    describe port(443) do
      it { should be_listening }
    end

    describe package($packagename) do
      it { is_expected.to be_installed }
    end

    describe service($servicename) do
      it { should be_enabled }
      it { is_expected.to be_running }
    end

    #default vhost
    describe file($defaultsiteconf) do
      it { should be_file }
      its(:content) { should match 'DocumentRoot /var/www/void' }
    end

    #test vhost - /etc/httpd/conf.d/sites/00-et2blog-80.conf
    describe file($et2blogconf) do
      it { should be_file }
      its(:content) { should match 'DocumentRoot /var/www/et2blog' }
    end

    #test vhost - /etc/httpd/conf.d/sites/00-et2blog-443.conf
    describe file($nssvhostconf) do
      it { should be_file }
      its(:content) { should match 'DocumentRoot /var/www/et2blog' }
      its(:content) { should_not match 'SSLEngine on' }
    end

    it "HTTP 200 SSL ZnVja3RoYXRiaXRjaAo" do
      expect(shell("curl -I https://localhost/check.rspec --insecure 2>/dev/null | head -n1 | grep 'HTTP/1.1 200 OK'").exit_code).to be_zero
    end

    it "cname SSL cert ZnVja3RoYXRiaXRjaAo" do
      expect(shell("echo | openssl s_client -connect localhost:443 2>/dev/null  | openssl x509 -noout -subject | grep 'CN=www.ZnVja3RoYXRiaXRjaAo.com'").exit_code).to be_zero
    end

    it "TLSv1 supported" do
      expect(shell("echo | openssl s_client -connect localhost:443 -tls1 2>&1 | grep 'Session-ID:' | awk '{ print $NF }' | grep -v 'Session-ID:'").exit_code).to be_zero
    end

    it "key size: 2048" do
      expect(shell("echo | openssl s_client -connect localhost:443 2>&1 | grep 'Server public key' | grep 2048").exit_code).to be_zero
    end

  end

end
