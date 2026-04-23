# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::instance' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'example' }
      let(:params) { {} }

      context 'with victorialogs class' do
        let(:pre_condition) { 'class { "victorialogs": version => "1.2.3" }' }

        context 'with default params' do
          it do
            is_expected.to contain_systemd__unit_file('victorialogs-example.service')
              .with_ensure('present')
              .with_active(true)
              .with_enable(true)
              .with_content(%r{^Description=VictoriaLogs example$})
              .with_content(%r{^User=victorialogs$})
              .with_content(%r{^Group=victorialogs$})
              .with_content(%r{^ExecStart=/usr/local/bin/victoria-logs-prod$})
          end
        end

        context 'with service_active=false' do
          let(:params) { super().merge(service_active: false) }

          it { is_expected.to contain_systemd__unit_file('victorialogs-example.service').with_active(false) }
        end

        context 'with service_enable=false' do
          let(:params) { super().merge(service_enable: false) }

          it { is_expected.to contain_systemd__unit_file('victorialogs-example.service').with_enable(false) }
        end

        context 'with service_name set' do
          let(:params) { super().merge(service_name: 'victorialogs') }

          it { is_expected.to contain_systemd__unit_file('victorialogs.service') }
        end

        context 'with user set' do
          let(:params) { super().merge(user: 'test') }

          it { is_expected.to contain_systemd__unit_file('victorialogs-example.service').with_content(%r{^User=test$}) }
        end

        context 'with group set' do
          let(:params) { super().merge(group: 'test') }

          it { is_expected.to contain_systemd__unit_file('victorialogs-example.service').with_content(%r{^Group=test$}) }
        end

        context 'with binary_path set' do
          let(:params) { super().merge(binary_path: '/opt/bin/victorialogs') }

          it { is_expected.to contain_systemd__unit_file('victorialogs-example.service').with_content(%r{^ExecStart=/opt/bin/victorialogs$}) }
        end

        context 'with options set' do
          let(:params) do
            super().merge(
              options: {
                common: {
                  'storageDataPath' => '/var/lib/victorialogs/data00',
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
            is_expected.to contain_systemd__unit_file('victorialogs-example.service')
              .with_content(%r{^ExecStart=/usr/local/bin/victoria-logs-prod \\$})
              .with_content(%r{^  -storageDataPath=/var/lib/victorialogs/data00 \\$})
              .with_content(%r{^  -syslog.listenAddr.tcp=:1234 \\$})
              .with_content(%r{^  -syslog.listenAddr.tcp=:2345 \\$})
          end
        end

        context 'with ensure=>absent' do
          let(:params) { super().merge(ensure: 'absent') }

          it do
            is_expected.to contain_systemd__unit_file('victorialogs-example.service')
              .with_ensure('absent')
              .with_active(false)
              .with_enable(false)
          end
        end
      end

      context 'with victorialogs class and install_method=package' do
        let(:pre_condition) { 'class { "victorialogs": install_method => "package" }' }

        context 'with default params' do
          it do
            is_expected.to contain_systemd__unit_file('victorialogs-example.service')
              .with_ensure('present')
              .with_active(true)
              .with_enable(true)
              .with_content(%r{^Description=VictoriaLogs example$})
              .with_content(%r{^User=victorialogs$})
              .with_content(%r{^Group=victorialogs$})
              .with_content(%r{^ExecStart=/usr/bin/victoria-logs-prod$})
          end
        end
      end

      context 'without victorialogs class' do
        let(:params) do
          {
            service_name: 'victorialogs',
            user: 'foo',
            group: 'foo',
            binary_path: '/usr/bin/victorialogs',
          }
        end

        it do
          is_expected.to contain_systemd__unit_file('victorialogs.service')
            .with_content(%r{^User=foo$})
            .with_content(%r{^Group=foo$})
            .with_content(%r{^ExecStart=/usr/bin/victorialogs$})
        end
      end
    end
  end
end
