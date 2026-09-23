# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::vlagent::instance' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'example' }
      # At least one remoteWrite.url is required unless $ensure is 'absent'
      let(:params) do
        {
          options: {
            common: {
              'remoteWrite.url' => 'http://localhost:9428/insert/native',
            },
          },
        }
      end

      context 'with victorialogs::vlagent' do
        let(:pre_condition) { 'class { "victorialogs::vlagent": version => "1.2.3" }' }

        it do
          is_expected.to contain_systemd__unit_file('vlagent-example.service')
            .with_ensure('present')
            .with_active(true)
            .with_enable(true)
            .with_content(%r{^Description=VictoriaLogs vlagent example$})
            .with_content(%r{^User=vlagent$})
            .with_content(%r{^Group=vlagent$})
            .with_content(%r{^ExecStart=/usr/local/bin/vlagent-prod \\$})
            .with_content(%r{^  -remoteWrite.url=http://localhost:9428/insert/native$})
        end

        context 'with service_active=false' do
          let(:params) { super().merge(service_active: false) }

          it { is_expected.to contain_systemd__unit_file('vlagent-example.service').with_active(false) }
        end

        context 'with service_enable=false' do
          let(:params) { super().merge(service_enable: false) }

          it { is_expected.to contain_systemd__unit_file('vlagent-example.service').with_enable(false) }
        end

        context 'with service_name set' do
          let(:params) { super().merge(service_name: 'vlagent') }

          it { is_expected.to contain_systemd__unit_file('vlagent.service') }
        end

        context 'with user set' do
          let(:params) { super().merge(user: 'test') }

          it { is_expected.to contain_systemd__unit_file('vlagent-example.service').with_content(%r{^User=test$}) }
        end

        context 'with group set' do
          let(:params) { super().merge(group: 'test') }

          it { is_expected.to contain_systemd__unit_file('vlagent-example.service').with_content(%r{^Group=test$}) }
        end

        context 'with binary_path set' do
          let(:params) { super().merge(binary_path: '/opt/bin/vlagent') }

          it { is_expected.to contain_systemd__unit_file('vlagent-example.service').with_content(%r{^ExecStart=/opt/bin/vlagent \\$}) }
        end

        context 'with options set' do
          let(:params) do
            super().merge(
              options: {
                common: {
                  'remoteWrite.url' => 'http://example.tld:9428/insert/native',
                },
                'syslog-input-1': {
                  'syslog.listenAddr.tcp' => ':1234',
                  'syslog.tenantID.tcp' => '123:0',
                },
                'syslog-input-2': {
                  'syslog.listenAddr.tcp' => ':2345',
                  'syslog.tenantID.tcp' => '234:0',
                },
              },
            )
          end

          it do
            is_expected.to contain_systemd__unit_file('vlagent-example.service')
              .with_content(%r{^ExecStart=/usr/local/bin/vlagent-prod \\$})
              .with_content(%r{^  -remoteWrite.url=http://example.tld:9428/insert/native \\$})
              .with_content(%r{^  -syslog.listenAddr.tcp=:1234 \\$})
              .with_content(%r{^  -syslog.listenAddr.tcp=:2345 \\$})
          end
        end

        context 'with ensure=>absent' do
          let(:params) { { ensure: 'absent' } }

          it do
            is_expected.to contain_systemd__unit_file('vlagent-example.service')
              .with_ensure('absent')
              .with_active(false)
              .with_enable(false)
          end
        end
      end

      context 'with victorialogs::vlagent class and ensure=absent' do
        let(:pre_condition) do
          <<-PUPPET
          class { 'victorialogs::vlagent':
            version => "1.2.3",
            ensure => 'absent',
          }
          PUPPET
        end

        it do
          is_expected.to contain_systemd__unit_file('vlagent-example.service')
            .with_ensure('absent')
            .with_active(false)
            .with_enable(false)
        end
      end

      context 'with victorialogs::vlagent class and install_method=package' do
        let(:pre_condition) do
          <<-PUPPET
          class { 'victorialogs::vlagent':
            install_method => 'package',
            package_name => 'vlagent',
            binary_path => '/usr/bin/vlagent-prod',
          }
          PUPPET
        end

        it do
          is_expected.to contain_systemd__unit_file('vlagent-example.service')
            .with_ensure('present')
            .with_active(true)
            .with_enable(true)
            .with_content(%r{^Description=VictoriaLogs vlagent example$})
            .with_content(%r{^User=vlagent$})
            .with_content(%r{^Group=vlagent$})
            .with_content(%r{^ExecStart=/usr/bin/vlagent-prod \\$})
        end
      end

      context 'without victorialogs::vlagent class' do
        let(:params) do
          {
            service_name: 'vlagent',
            user: 'foo',
            group: 'foo',
            binary_path: '/usr/bin/vlagent',
            options: {
              common: {
                'remoteWrite.url' => 'http://localhost:9428/insert/native',
              },
            },
          }
        end

        it do
          is_expected.to contain_systemd__unit_file('vlagent.service')
            .with_content(%r{^User=foo$})
            .with_content(%r{^Group=foo$})
            .with_content(%r{^ExecStart=/usr/bin/vlagent \\$})
        end
      end
    end
  end
end
