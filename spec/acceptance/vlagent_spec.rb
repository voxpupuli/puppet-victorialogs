# frozen_string_literal: true

require 'spec_helper_acceptance'

VLAGENT_TEST_VERSION = '1.51.0' # Keep it one version below latest
VLAGENT_TEST_VERSION_FOR_RE = VLAGENT_TEST_VERSION.gsub('.', '[.]')
VLOGSCLI_TEST_VERSION = '1.52.0'

describe 'victorialogs:vlagent class' do
  context 'with version specified' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs::vlagent':
          version => '#{VLAGENT_TEST_VERSION}',
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(command('/usr/local/bin/vlagent-prod -version').stdout).to match(%r{^vlagent-.*-v#{VLAGENT_TEST_VERSION_FOR_RE}-.*$}) }
      it { expect(user('vlagent')).to exist }
      it { expect(group('vlagent')).to exist }
    end
  end

  context 'with vlogcli of a different version' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs::vlagent':
          version => '#{VLAGENT_TEST_VERSION}',
        }
        class { 'victorialogs::vlogscli':
          version => '#{VLOGSCLI_TEST_VERSION}',
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(command('/usr/local/bin/vlagent-prod -version').stdout).to match(%r{^vlagent-.*-v#{VLAGENT_TEST_VERSION_FOR_RE}-.*$}) }
      it { expect(command('/usr/local/bin/vlogscli -version').stdout).to match(%r{^vlogscli-.*-v#{VLOGSCLI_TEST_VERSION.gsub('.', '[.]')}-.*$}) }
    end
  end

  describe 'with instances specified' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs::vlagent':
          version => '#{VLAGENT_TEST_VERSION}',
          instances => {
            test1 => {
              ensure => 'absent',
            },
            test2 => {
              options => {
                common => {
                  'remoteWrite.url' => 'http://localhost:9428/insert/native',
                },
                'syslog-input-1' => {
                  'syslog.listenAddr.tcp' => ':12345',
                },
              },
            },
          },
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(port(9429)).to be_listening }
      it { expect(port(12_345)).to be_listening }

      it do
        service = service('vlagent-test1')
        expect(service).not_to be_enabled
        expect(service).not_to be_running
      end

      it do
        service = service('vlagent-test2')
        expect(service).to be_enabled
        expect(service).to be_running
      end
    end
  end

  describe 'with ensure => absent' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs::vlagent':
          ensure => 'absent',
          version => '#{VLAGENT_TEST_VERSION}',
          instances => {
            test1 => {
              ensure => 'absent',
            },
            test2 => {
              options => {
                common => {
                  'remoteWrite.url' => 'http://localhost:9428/insert/native',
                },
                'syslog-input-1' => {
                  'syslog.listenAddr.tcp' => ':12345',
                },
              },
            },
          },
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(file('/usr/local/bin/vlagent-prod')).not_to exist }
      it { expect(user('vlagent')).not_to exist }
      it { expect(group('vlagent')).not_to exist }
      it { expect(port(9429)).not_to be_listening }

      it do
        service = service('vlagent-test1')
        expect(service).not_to be_enabled
        expect(service).not_to be_running
      end

      it do
        service = service('vlagent-test2')
        expect(service).not_to be_enabled
        expect(service).not_to be_running
      end
    end
  end

  # vlagent enterprise edition requires a license to be started.
  # So we just check it was applied ok and CLI version is good.
  describe 'with enterprise edition specified' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs::vlagent':
          version => '#{VLAGENT_TEST_VERSION}',
          edition => 'enterprise',
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(command('/usr/local/bin/vlagent-prod -version').stdout).to match(%r{^vlagent-.*-v#{VLAGENT_TEST_VERSION_FOR_RE}-enterprise-.*$}) }
    end
  end
end
