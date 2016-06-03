require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context ' enabling sorrypage' do
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
        site_running => false,
        custom_sorrypage => { 'path' => '/var/www/et2blog',                    
                               'errordocument' => 'maintenance.html',
        },
      }

      file { '/var/www/et2blog/maintenance.html':
        ensure => 'present',
        content => "\nSorryPage\n",
        require => Apache::Vhost['et2blog'],
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

    it "check 503 et2blog" do
      expect(shell("curl -I 127.0.0.1/ -H 'Host: et2blog' 2>/dev/null | head -n1 | grep 'HTTP/1.1 503'").exit_code).to be_zero
    end

    it "check content et2blog" do
      expect(shell("curl 127.0.0.1/ -H 'Host: et2blog' 2>/dev/null | grep SorryPage").exit_code).to be_zero
    end

  end

  context ' enabling sorrypage and exclude healthcheck' do
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
        site_running => false,
        custom_sorrypage => { 'path' => '/var/www/et2blog',                    
                              'errordocument' => 'maintenance.html',
                              'healthcheck' => 'healthcheck.html'
        },
      }

      file { '/var/www/et2blog/maintenance.html':
        ensure => 'present',
        content => "\nSorryPage\n",
        require => Apache::Vhost['et2blog'],
      }


      file { '/var/www/et2blog/healthcheck.html':
        ensure => 'present',
        content => "\nHealthCheck\n",
        require => Apache::Vhost['et2blog'],
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

    it "check 503 et2blog" do
      expect(shell("curl -I 127.0.0.1/ -H 'Host: et2blog' 2>/dev/null | head -n1 | grep 'HTTP/1.1 503'").exit_code).to be_zero
    end

    it "check content et2blog" do
      expect(shell("curl 127.0.0.1/ -H 'Host: et2blog' 2>/dev/null | grep SorryPage").exit_code).to be_zero
    end

    it "check content et2blog healthcheck" do
      expect(shell("curl 127.0.0.1/healthcheck.html -H 'Host: et2blog' 2>/dev/null | grep HealthCheck").exit_code).to be_zero
    end

    it "check 200 et2blog healthcheck" do
      expect(shell("curl -I 127.0.0.1/healthcheck.html -H 'Host: et2blog' 2>/dev/null | head -n1 | grep 'HTTP/1.1 200 OK'").exit_code).to be_zero
    end

  end

end
