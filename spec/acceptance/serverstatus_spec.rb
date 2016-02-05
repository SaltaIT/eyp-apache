require 'spec_helper_acceptance'

describe 'apache class' do

  context 'basic setup' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      class { 'apache':
        listen => [ '80', '81' ],
      }

      apache::vhost {'default':
        defaultvh=>true,
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

    it "sleep 10 to make sure apache is started" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    it "curl to serverstatus http://localhost:80/server_status" do
      expect(shell("curl http://localhost:80/server_status | grep -q 'Apache Status'").exit_code).to be_zero
    end

    it "curl to serverstatus http://localhost:81/random_status" do
      expect(shell("curl http://localhost:81/random_status | grep -q 'Apache Status'").exit_code).to be_zero
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
    describe file("${baseconf}/conf.d/sites/00-et2blog-80.conf") do
      it { should be_file }
      its(:content) { should match '<Location /server-status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end
    describe file("${baseconf}/conf.d/sites/10-systemadmin.es-81.conf") do
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
      }

      apache::vhost {'default':
        defaultvh=>true,
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
        serverstatus_url => '/random_status',
        order     => '10',
        port      => '81',
        allowedip => ['1.1.1.1','2.2.2.2','4.4.4.4 5.5.5.5','127.','::1'],
      }

      EOF

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end

    it "sleep 10 to make sure apache is started" do
      expect(shell("sleep 10").exit_code).to be_zero
    end

    it "curl to serverstatus http://localhost:80/server_status" do
      expect(shell("curl http://localhost:80/server_status | grep -q 'Apache Status'").exit_code).to be_zero
    end

    it "curl to serverstatus http://localhost:81/random_status" do
      expect(shell("curl http://localhost:81/random_status | grep -q 'Apache Status'").exit_code).to be_zero
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
    describe file("${baseconf}/conf.d/sites/00-et2blog-80.conf") do
      it { should be_file }
      its(:content) { should match '<Location /server-status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end
    describe file("${baseconf}/conf.d/sites/10-systemadmin.es-81.conf") do
      it { should be_file }
      its(:content) { should match '<Location /random_status>' }
      its(:content) { should match 'SetHandler server-status' }
      its(:content) { should match '</Location>' }
    end

    #test vhost - /etc/httpd/conf.d/sites/00-et2blog-80.conf

  end

end
