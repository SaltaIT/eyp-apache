require 'spec_helper_acceptance'
require_relative './version.rb'

describe 'apache class' do

  context 'includeconf' do
    # Using puppet_apply as a helper
    it 'should work with no errors' do
      pp = <<-EOF

      file { '/demo.conf':
        ensure => 'present',
        owner => 'root',
        group => 'root',
        mode => '0666',
        content => '#',
      }

      ->

      class { 'apache':
        manage_docker_service => true,
      }

      apache::include_conf { '/etc:
        files => [ 'demo.conf' ],
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

    # include
    describe file($includesconf) do
      it { should be_file }
      its(:content) { should match '/etc/demo.conf' }
    end

  end

end
