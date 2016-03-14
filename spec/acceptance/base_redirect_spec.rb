require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context 'redirect' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        server_admin=> 'webmaster@localhost',
        maxclients=> '150',
        maxrequestsperchild=>'1000',
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

      apache::redirect { 'et2blog':
    		path => '/',
    		url => 'http://systemadmin.es/',
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

    describe file($et2blogconf) do
      it { should be_file }
      its(:content) { should match 'Redirect' }
      its(:content) { should match 'http://systemadmin.es/' }
    end

    it "redirect 301" do
      expect(shell("curl -I localhost -H 'Host: et2blog' 2>/dev/null | grep '^HTTP' | head -n1 | grep 301").exit_code).to be_zero
    end

    it "redirect url" do
      expect(shell("curl -I localhost -H 'Host: et2blog' 2>/dev/null | grep '^Location' | head -n1  | grep systemadmin.es").exit_code).to be_zero
    end

  end

  context 'redirectmatch' do
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

      apache::redirect { 'et2blog':
        match => '/lol',
        url => 'http://systemadmin.es/',
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

    describe file($et2blogconf) do
      it { should be_file }
      its(:content) { should match 'RedirectMatch' }
      its(:content) { should match 'http://systemadmin.es/' }
    end

    it "redirect 301" do
      expect(shell("curl -I localhost/lol -H 'Host: et2blog' 2>/dev/null | grep '^HTTP' | head -n1 | grep 301").exit_code).to be_zero
    end

    it "redirect url" do
      expect(shell("curl -I localhost/lol -H 'Host: et2blog' 2>/dev/null | grep '^Location' | head -n1  | grep systemadmin.es").exit_code).to be_zero
    end

  end

end
