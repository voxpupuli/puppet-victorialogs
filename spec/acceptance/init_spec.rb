# frozen_string_literal: true

require 'spec_helper_acceptance'

TEST_VERSION = '1.49.0'

describe 'victorialogs class' do
  describe 'with version specified' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs':
          version => '#{TEST_VERSION}',
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(command('/usr/local/bin/victoria-logs-prod -version').stdout).to match(%r{^victoria-logs-.*-v#{TEST_VERSION.gsub('.', '\.')}-.*$}) }
      it { expect(user('victorialogs')).to exist }
      it { expect(group('victorialogs')).to exist }
      it { expect(file('/var/lib/victorialogs/victoria-logs-data')).to be_directory }

      it do
        service = service('victorialogs-single')
        expect(service).to be_enabled
        expect(service).to be_running
      end

      it { expect(curl_command('http://localhost:9428/').stdout).to match(%r{Version victoria-logs-.*-v#{TEST_VERSION.gsub('.', '\.')}}) }
    end
  end

  describe 'with instances specified' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs':
          version => '#{TEST_VERSION}',
          instances => {
            single => {
              ensure => 'absent',
              options => {
                common => {
                  '-storageDataPath' => '/var/lib/victorialogs/victoria-logs-data',
                },
              },
            },
            test => {
              options => {
                common => {
                  '-storageDataPath' => '/var/lib/victorialogs/data00',
                },
                'syslog-input-1' => {
                  '-syslog.listenAddr.tcp' => ':12345',
                },
              },
            },
          },
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(command('/usr/local/bin/victoria-logs-prod -version').stdout).to match(%r{^victoria-logs-.*-v#{TEST_VERSION.gsub('.', '\.')}-.*$}) }
      it { expect(file('/var/lib/victorialogs/data00')).to be_directory }
      it { expect(port(9428)).to be_listening }
      it { expect(port(12_345)).to be_listening }

      it do
        service = service('victorialogs-single')
        expect(service).not_to be_enabled
        expect(service).not_to be_running
      end

      it do
        service = service('victorialogs-test')
        expect(service).to be_enabled
        expect(service).to be_running
      end
    end
  end

  describe 'with ensure => absent' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs':
          ensure => 'absent',
          version => '#{TEST_VERSION}',
          instances => {
            single => {
              options => {
                common => {
                  '-storageDataPath' => '/var/lib/victorialogs/victoria-logs-data',
                },
              },
            },
            test => {
              options => {
                common => {
                  '-storageDataPath' => '/srv/victorialogs00',
                },
                'syslog-input-1' => {
                  '-syslog.listenAddr.tcp' => ':12345',
                },
              },
            },
          },
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(file('/usr/local/bin/victoria-logs-prod')).not_to exist }
      it { expect(user('victorialogs')).not_to exist }
      it { expect(group('victorialogs')).not_to exist }
      it { expect(file('/var/lib/victorialogs')).not_to exist }

      it do
        service = service('victorialogs-single')
        expect(service).not_to be_enabled
        expect(service).not_to be_running
      end

      it do
        service = service('victorialogs-test')
        expect(service).not_to be_enabled
        expect(service).not_to be_running
      end

      it { expect(port(9428)).not_to be_listening }
    end
  end

  # VictoriaLogs enterprise edition requires a license to be started.
  # So we just check it was applied ok and CLI version is good.
  describe 'with enterprise edition specified' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'victorialogs':
          version => '#{TEST_VERSION}',
          edition => 'enterprise',
          instances => {},
        }
        PUPPET
      end
    end

    describe 'serverspec tests' do
      it { expect(command('/usr/local/bin/victoria-logs-prod -version').stdout).to match(%r{^victoria-logs-.*-v#{TEST_VERSION.gsub('.', '\.')}-enterprise-.*$}) }
    end
  end
end
