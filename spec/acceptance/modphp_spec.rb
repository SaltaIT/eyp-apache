require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'mod_php class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        manage_docker_service => true,
      }

    	apache::vhost {'default':
    		defaultvh=>true,
    		documentroot => '/var/www/void',
    	}

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
      }

    	class { 'apache::mod::php': }

      file { '/var/www/void/phpinfo.php':
        ensure=> 'present',
        mode => '0666',
        content => "<?php\n  phpinfo();\n?>\n",
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
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

    #et2blog
    describe file($et2blogconf) do
      it { should be_file }
      its(:content) { should match 'DocumentRoot /var/www/et2blog' }
    end

    it "apache configtest" do
      expect(shell("apachectl configtest").exit_code).to be_zero
    end

    it "php module loaded" do
      expect(shell("apachectl -M | grep php").exit_code).to be_zero
    end

    it "phpinfo HTTP 200" do
      expect(shell("curl -I localhost/phpinfo.php 2>/dev/null| grep ^HTTP | grep 200").exit_code).to be_zero
    end

    it "phpinfo" do
      expect(shell("curl localhost/phpinfo.php 2>/dev/null| grep 'PHP License'").exit_code).to be_zero
    end

  end

  context 'php uninstall' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        manage_docker_service => true,
      }

    	apache::vhost {'default':
    		defaultvh=>true,
    		documentroot => '/var/www/void',
    	}

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
      }

    	class { 'apache::mod::php':
        ensure => 'purged',
      }

      file { '/var/www/void/phpinfo.php':
        ensure=> 'present',
        mode => '0666',
        content => "<?php\n  phpinfo();\n?>\n",
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
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

    it "apache configtest" do
      expect(shell("apachectl configtest").exit_code).to be_zero
    end

    it "phpinfo HTTP 200" do
      expect(shell("curl -I localhost/phpinfo.php 2>/dev/null| grep ^HTTP | grep 200").exit_code).to be_zero
    end

    it "phpinfo contents" do
      expect(shell("curl localhost/phpinfo.php 2>/dev/null| grep 'phpinfo()'").exit_code).to be_zero
    end


  end

end
