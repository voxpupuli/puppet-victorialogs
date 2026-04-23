# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default params' do
        it { is_expected.to compile.and_raise_error(%r{version is required}) }
      end

      context 'with install_method=package' do
        let(:params) { { install_method: 'package' } }

        it { is_expected.not_to contain_file('/opt/victorialogs-1.2.3-oss') }
        it { is_expected.not_to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz') }
        it { is_expected.not_to contain_file('/opt/victorialogs-1.2.3-oss/victoria-logs-prod') }
        it { is_expected.not_to contain_file('/usr/local/bin/victoria-logs-prod') }
        it { is_expected.to contain_package('victorialogs') }
        it { is_expected.to contain_victorialogs__instance('single').with_binary_path('/usr/bin/victoria-logs-prod') }

        context 'with package name set' do
          let(:params) { super().merge(package_name: 'foo') }

          it { is_expected.to contain_package('foo') }
        end

        context 'with version set' do
          let(:params) { super().merge(version: '1.2.3-1') }

          it { is_expected.to contain_package('victorialogs').with_ensure('1.2.3-1') }
        end

        context 'with binary_path set' do
          let(:params) { super().merge(binary_path: '/opt/bin/victorialogs') }

          it { is_expected.to contain_victorialogs__instance('single').with_binary_path('/opt/bin/victorialogs') }
        end
      end

      # With install_method=none user should specify where the victorialogs binary is explicitly
      context 'with install_method=none' do
        let(:params) do
          {
            install_method: 'none',
            binary_path: '/opt/bin/victorialogs',
          }
        end

        it { is_expected.not_to contain_file('/opt/victorialogs-1.2.3-oss') }
        it { is_expected.not_to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz') }
        it { is_expected.not_to contain_file('/opt/victorialogs-1.2.3-oss/victoria-logs-prod') }
        it { is_expected.not_to contain_file('/usr/local/bin/victoria-logs-prod') }
        it { is_expected.not_to contain_package('victorialogs') }
        it { is_expected.to contain_victorialogs__instance('single').with_binary_path('/opt/bin/victorialogs') }
      end

      context 'with install_method=archive and version set' do
        let(:params) { { version: '1.2.3' } }

        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_group('victorialogs').with_ensure('present') }

        it do
          is_expected.to contain_user('victorialogs')
            .with_ensure('present')
            .with_gid('victorialogs')
            .with_shell('/usr/sbin/nologin')
            .with_home('/var/lib/victorialogs')
        end

        it do
          is_expected.to contain_file('/var/lib/victorialogs')
            .with_ensure('directory')
            .with_mode('0750')
            .with_owner('victorialogs')
            .with_group('victorialogs')
        end

        it { is_expected.to contain_file('/opt/victorialogs-1.2.3-oss') }

        it do
          is_expected.to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz')
            .with_ensure('present')
            .with_source(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3.tar.gz',
            )
            .with_checksum_url(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3_checksums.txt',
            )
            .with_extract_path('/opt/victorialogs-1.2.3-oss')
            .with_creates('/opt/victorialogs-1.2.3-oss/victoria-logs-prod')
            .that_comes_before('File[/opt/victorialogs-1.2.3-oss/victoria-logs-prod]')
        end

        it { is_expected.to contain_file('/opt/victorialogs-1.2.3-oss/victoria-logs-prod').with_ensure('file') }

        it do
          is_expected.to contain_file('/usr/local/bin/victoria-logs-prod')
            .with_ensure('link')
            .with_target('/opt/victorialogs-1.2.3-oss/victoria-logs-prod')
        end

        it { is_expected.not_to contain_package('victorialogs') }

        it do
          is_expected.to contain_victorialogs__instance('single')
            .with_ensure('present')
            .with_service_active(true)
            .with_service_enable(true)
            .with_service_name('victorialogs-single')
            .with_user('victorialogs')
            .with_group('victorialogs')
            .with_binary_path('/usr/local/bin/victoria-logs-prod')
            .with_options({ 'common' => { 'storageDataPath' => '/var/lib/victorialogs/victoria-logs-data' } })
            .that_subscribes_to('Class[Victorialogs::Install]')
            .that_requires('File[/var/lib/victorialogs]')
            .that_requires('User[victorialogs]')
            .that_requires('Group[victorialogs]')
        end

        context 'with edition=>enterprise' do
          let(:params) { super().merge(edition: 'enterprise') }

          it { is_expected.to contain_file('/opt/victorialogs-1.2.3-enterprise') }
          it { is_expected.to contain_file('/opt/victorialogs-1.2.3-enterprise/victoria-logs-prod') }

          it do
            is_expected.to contain_archive('/tmp/victorialogs-1.2.3-enterprise.tar.gz')
              .with_source(
                'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3-enterprise.tar.gz',
              )
              .with_checksum_url(
                'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3-enterprise_checksums.txt',
              )
              .with_extract_path('/opt/victorialogs-1.2.3-enterprise')
              .with_creates('/opt/victorialogs-1.2.3-enterprise/victoria-logs-prod')
              .that_comes_before('File[/opt/victorialogs-1.2.3-enterprise/victoria-logs-prod]')
          end
        end

        context 'with manage_group=false' do
          let(:params) { super().merge(manage_group: false) }

          it { is_expected.not_to contain_group('victorialogs') }
        end

        context 'with group set' do
          let(:params) { super().merge(group: 'foo') }

          it { is_expected.to contain_group('foo') }
          it { is_expected.to contain_file('/var/lib/victorialogs').with_group('foo') }
          it { is_expected.to contain_victorialogs__instance('single').with_group('foo') }
        end

        context 'with manage_user=false' do
          let(:params) { super().merge(manage_user: false) }

          it { is_expected.not_to contain_user('victorialogs') }
        end

        context 'with user set' do
          let(:params) { super().merge(user: 'foo') }

          it { is_expected.to contain_user('foo') }
          it { is_expected.to contain_file('/var/lib/victorialogs').with_owner('foo') }
          it { is_expected.to contain_victorialogs__instance('single').with_user('foo') }
        end

        context 'with user shell set' do
          let(:params) { super().merge(shell: '/bin/bash') }

          it { is_expected.to contain_user('victorialogs').with_shell('/bin/bash') }
        end

        context 'with user homedir set' do
          let(:params) { super().merge(homedir: '/srv/victorialogs') }

          it { is_expected.to contain_user('victorialogs').with_home('/srv/victorialogs') }
          it { is_expected.to contain_file('/srv/victorialogs') }
        end

        context 'with user homedir attributes set' do
          let(:params) { super().merge(homedir_mode: '0751', homedir_owner: 'foo', homedir_group: 'bar') }

          it { is_expected.to contain_file('/var/lib/victorialogs').with_mode('0751').with_owner('foo').with_group('bar') }
        end

        context 'with download & checksum URLs set' do
          let(:params) do
            super().merge(
              download_url: 'https://example.tld/foo.tar.gz',
              checksum_url: 'https://example.tld/foo-checksums.txt',
            )
          end

          it do
            is_expected.to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz')
              .with_source('https://example.tld/foo.tar.gz')
              .with_checksum_url('https://example.tld/foo-checksums.txt')
          end
        end

        context 'with binary_path set' do
          let(:params) { super().merge(binary_path: '/opt/bin/victorialogs') }

          it { is_expected.to contain_file('/opt/bin/victorialogs') }
          it { is_expected.to contain_victorialogs__instance('single').with_binary_path('/opt/bin/victorialogs') }
        end

        context 'with instances set' do
          let(:params) do
            super().merge(
              instances: {
                foo: {
                  options: {
                    common: {
                      'storageDataPath' => '/var/lib/victorialogs/foo',
                    },
                  },
                },
                bar: {
                  options: {
                    common: {
                      'storageDataPath' => '/var/lib/victorialogs/bar',
                    },
                  },
                },
              },
            )
          end

          %w[foo bar].each do |inst|
            it do
              is_expected.to contain_victorialogs__instance(inst)
                .with_ensure('present')
                .with_service_name("victorialogs-#{inst}")
                .with_options('common' => { 'storageDataPath' => "/var/lib/victorialogs/#{inst}" })
            end
          end

          context 'with ensure=>absent' do
            let(:params) { super().merge(ensure: 'absent') }

            %w[foo bar].each do |inst|
              it do
                is_expected.to contain_victorialogs__instance(inst)
                  .with_ensure('absent')
                  .with_service_name("victorialogs-#{inst}")
                  .with_options('common' => { 'storageDataPath' => "/var/lib/victorialogs/#{inst}" })
              end
            end
          end
        end

        context 'with ensure=>absent' do
          let(:params) { super().merge(ensure: 'absent') }

          it { is_expected.to contain_group('victorialogs').with_ensure('absent') }
          it { is_expected.to contain_user('victorialogs').with_ensure('absent') }

          it do
            is_expected.to contain_file('/var/lib/victorialogs')
              .with_ensure('absent')
              .with_recurse(true)
              .with_force(true)
          end

          it do
            is_expected.to contain_file('/opt/victorialogs-1.2.3-oss')
              .with_ensure('absent')
              .with_recurse(true)
              .with_force(true)
          end

          it { is_expected.not_to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz') }
          it { is_expected.not_to contain_file('/opt/victorialogs-1.2.3-oss/victoria-logs-prod') }
          it { is_expected.to contain_file('/usr/local/bin/victoria-logs-prod').with_ensure('absent') }

          it do
            is_expected.to contain_victorialogs__instance('single')
              .with_ensure('absent')
              .that_comes_before('Class[Victorialogs::Install]')
              .that_comes_before('File[/var/lib/victorialogs]')
              .that_comes_before('User[victorialogs]')
              .that_comes_before('Group[victorialogs]')
          end
        end
      end
    end
  end
end
