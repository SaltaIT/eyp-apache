require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context 'mod_deflate' do
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

      class { 'apache::mod::deflate':
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
    describe file($modulesconf) do
      it { should be_file }
      its(:content) { should match 'deflate_module' }
    end

    #default vhost
    describe file($deflateconf) do
      it { should be_file }
      its(:content) { should match 'DEFLATE' }
    end

  end

end
