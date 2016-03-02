require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        listen => [ '80', '81' ],
        manage_docker_service => true,
      }

      apache::vhost {'default':
        defaultvh => true,
        documentroot => '/var/www/void',
      }

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
      }

      apache::serverstatus {'et2blog':}

      apache::vhost {'systemadmin.es':
        order        => '10',
        port         => '81',
        documentroot => '/var/www/systemadmin',
      }

      apache::serverstatus {'systemadmin.es':
        order     => '10',
        port      => '81',
        allowedip => ['1.1.1.1','2.2.2.2','4.4.4.4 5.5.5.5','127.','::1'],
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

    it "curl defaultvh http://localhost:80/server-status" do
      expect(shell("curl http://localhost:80/server-status 2>/dev/null | grep -i 'Apache Server Status for' >/dev/null").exit_code).to be_zero
    end

    it "curl et2blog http://localhost:80/server-status" do
      expect(shell("curl http://localhost:80/server-status -H 'Host: et2blog' 2>/dev/null | grep -i 'Apache Server Status for' >/dev/null").exit_code).to be_zero
    end

    it "curl port 81  http://localhost:81/server-status" do
      expect(shell("curl http://localhost:81/server-status 2>/dev/null | grep -i 'Apache Server Status for' >/dev/null").exit_code).to be_zero
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
    describe file($defaultvhconf) do
      it { should be_file }
      its(:content) { should match '<Location /server-status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end

    describe file($et2blogconf) do
      it { should be_file }
      its(:content) { should match '<Location /server-status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end

    describe file($systemadminconf) do
      it { should be_file }
      its(:content) { should match '<Location /server-status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end

    #test vhost - /etc/httpd/conf.d/sites/00-et2blog-80.conf

  end

  context 'custom url' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        listen => [ '80', '81' ],
        manage_docker_service => true,
      }

      apache::vhost {'default':
        defaultvh=>true,
        documentroot => '/var/www/void',
      }

      apache::vhost {'et2blog':
        documentroot => '/var/www/et2blog',
      }

      apache::serverstatus {'et2blog':
        serverstatus_url => '/random_status',
      }

      apache::vhost {'systemadmin.es':
        order        => '10',
        port         => '81',
        documentroot => '/var/www/systemadmin',
      }

      apache::serverstatus {'systemadmin.es':
        serverstatus_url => '/random_status',
        order     => '10',
        port      => '81',
        allowedip => ['1.1.1.1','2.2.2.2','4.4.4.4 5.5.5.5','127.','::1'],
      }

      apache::vhost {'awscli.com':
        order        => '11',
        port         => '81',
        documentroot => '/var/www/void',
      }

      apache::serverstatus {'awscli.com':
        serverstatus_url => '/fucker_status',
        order     => '11',
        port      => '81',
        allowedip => [ '1.1.1.1' ],
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

    it "curl defaultvh http://localhost:80/server-status" do
      expect(shell("curl http://localhost:80/server-status 2>/dev/null | grep -i 'Apache Server Status for' >/dev/null").exit_code).to be_zero
    end

    it "curl et2blog http://localhost:80/random_status" do
      expect(shell("curl http://localhost:80/random_status -H 'Host: et2blog' 2>/dev/null | grep -i 'Apache Server Status for' >/dev/null").exit_code).to be_zero
    end

    it "curl port 81 http://localhost:81/random_status" do
      expect(shell("curl http://localhost:81/random_status 2>/dev/null | grep -i 'Apache Server Status for' >/dev/null").exit_code).to be_zero
    end

    it "403 forbidden curl port 81 http://awscli.com:81/random_status" do
      expect(shell("curl -I localhost:81/fucker_status -H 'Host: awscli.com' 2>/dev/null | grep ^HTT | grep -i '403 Forbidden' > /dev/null").exit_code).to be_zero
    end

    describe port(80) do
      it { should be_listening }
    end

    describe port(81) do
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
    describe file($defaultvhconf) do
      it { should be_file }
      its(:content) { should match '<Location /server-status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end

    describe file($et2blogconf) do
      it { should be_file }
      its(:content) { should match '<Location /random_status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end
    describe file($systemadminconf) do
      it { should be_file }
      its(:content) { should match '<Location /random_status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end

    #test vhost - /etc/httpd/conf.d/sites/00-et2blog-80.conf
  end

end
