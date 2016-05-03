require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context 'mod_proxy and co' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        listen => [ '80' ],
        manage_docker_service => true,
      }

      class { 'apache::mod::proxy': }
      class { 'apache::mod::proxyajp': }
      class { 'apache::mod::proxybalancer': }
      class { 'apache::mod::proxyconnect': }
      class { 'apache::mod::proxyhttp': }
      class { 'apache::mod::proxyftp': }

      apache::vhost {'default':
        defaultvh=>true,
        documentroot => '/var/www/void',
      }

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
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

    it "sleep 10 to make sure mod_proxy is started" do
      expect(shell("apachectl -M 2>&1 | grep proxy_module").exit_code).to be_zero
    end

    it "sleep 10 to make sure mod_proxy_ajp is started" do
      expect(shell("apachectl -M 2>&1 | grep proxy_ajp_module").exit_code).to be_zero
    end

    it "sleep 10 to make sure mod_proxy_balancer is started" do
      expect(shell("apachectl -M 2>&1 | grep proxy_balancer_module").exit_code).to be_zero
    end

    it "sleep 10 to make sure mod_proxy_connect is started" do
      expect(shell("apachectl -M 2>&1 | grep proxy_connect_module").exit_code).to be_zero
    end

    it "sleep 10 to make sure mod_proxy_http is started" do
      expect(shell("apachectl -M 2>&1 | grep proxy_http_module").exit_code).to be_zero
    end

    it "sleep 10 to make sure mod_proxy_ftp is started" do
      expect(shell("apachectl -M 2>&1 | grep proxy_ftp_module").exit_code).to be_zero
    end

  end

end
