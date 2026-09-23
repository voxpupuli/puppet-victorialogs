# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::vlagent' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'with default params' do
        it { is_expected.to compile.and_raise_error(%r{version is required}) }
      end

      context 'with install_method=package' do
        let(:params) { { install_method: 'package' } }

        it { is_expected.to compile.and_raise_error(%r{\$package_name is required}) }

        context 'with package name set' do
          let(:params) { super().merge(package_name: 'foo') }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_package('foo').with_ensure('installed') }
          it { is_expected.to have_archive_resource_count(0) }

          context 'with ensure=>absent' do
            let(:params) { super().merge(ensure: 'absent') }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_package('foo').with_ensure('absent') }
          end
        end

        context 'with version set' do
          let(:params) { super().merge(package_name: 'foo', version: '1.2.3-1') }

          it { is_expected.to contain_package('foo').with_ensure('1.2.3-1') }

          context 'with ensure=>absent' do
            let(:params) { super().merge(ensure: 'absent') }

            it { is_expected.to compile.with_all_deps }
            it { is_expected.to contain_package('foo').with_ensure('absent') }
          end
        end
      end

      context 'with install_method=none' do
        let(:params) { { install_method: 'none', binary_path: '/opt/bin/vlagent' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_package_resource_count(0) }
        it { is_expected.to have_archive_resource_count(0) }
      end

      context 'with default install_method (archive) and version set' do
        let(:params) { { version: '1.2.3' } }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_victorialogs__install__os_user('vlagent')
            .with_ensure('present')
            .with_manage_group(true)
            .with_group('vlagent')
            .with_manage_user(true)
            .with_user('vlagent')
            .with_shell('/usr/sbin/nologin')
            .with_homedir('/var/lib/vlagent')
            .with_manage_homedir(true)
            .with_homedir_mode('0750')
            .with_homedir_owner('vlagent')
            .with_homedir_group('vlagent')
        end

        it do
          is_expected.to contain_file('/opt/vlagent-1.2.3-oss')
            .with_ensure('directory')
            .without_recurse
            .without_force
        end

        it do
          is_expected.to contain_archive('/tmp/vlagent-1.2.3-oss.tar.gz')
            .with_source(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3.tar.gz',
            )
            .with_checksum_url(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3_checksums.txt',
            )
            .with_extract_path('/opt/vlagent-1.2.3-oss')
            .with_creates('/opt/vlagent-1.2.3-oss/vlagent-prod')
            .that_comes_before('File[/opt/vlagent-1.2.3-oss/vlagent-prod]')
        end

        it { is_expected.to contain_file('/opt/vlagent-1.2.3-oss/vlagent-prod').with_ensure('file') }

        it do
          is_expected.to contain_file('/usr/local/bin/vlagent-prod')
            .with_ensure('link')
            .with_target('/opt/vlagent-1.2.3-oss/vlagent-prod')
        end

        context 'with edition=>enterprise' do
          let(:params) { super().merge(edition: 'enterprise') }

          it { is_expected.to contain_file('/opt/vlagent-1.2.3-enterprise').with_ensure('directory') }

          it do
            is_expected.to contain_archive('/tmp/vlagent-1.2.3-enterprise.tar.gz')
              .with_source(
                'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise.tar.gz',
              )
              .with_checksum_url(
                'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise_checksums.txt',
              )
              .with_extract_path('/opt/vlagent-1.2.3-enterprise')
              .with_creates('/opt/vlagent-1.2.3-enterprise/vlagent-prod')
              .that_comes_before('File[/opt/vlagent-1.2.3-enterprise/vlagent-prod]')
          end

          it { is_expected.to contain_file('/opt/vlagent-1.2.3-enterprise/vlagent-prod').with_ensure('file') }

          it do
            is_expected.to contain_file('/usr/local/bin/vlagent-prod')
              .with_ensure('link')
              .with_target('/opt/vlagent-1.2.3-enterprise/vlagent-prod')
          end
        end

        context 'with manage_group=false' do
          let(:params) { super().merge(manage_group: false) }

          it { is_expected.to contain_victorialogs__install__os_user('vlagent').with_manage_group(false) }
        end

        context 'with group set' do
          let(:params) { super().merge(group: 'foo') }

          it { is_expected.to contain_victorialogs__install__os_user('vlagent').with_group('foo') }
          it { is_expected.to contain_victorialogs__install__os_user('vlagent').with_homedir_group('foo') }
        end

        context 'with manage_user=false' do
          let(:params) { super().merge(manage_user: false) }

          it do
            is_expected.to contain_victorialogs__install__os_user('vlagent')
              .with_manage_user(false)
              .with_manage_group(false)
              .with_manage_homedir(false)
          end
        end

        context 'with user set' do
          let(:params) { super().merge(user: 'foo') }

          it { is_expected.to contain_victorialogs__install__os_user('foo') }
        end

        context 'with user shell set' do
          let(:params) { super().merge(shell: '/bin/bash') }

          it { is_expected.to contain_victorialogs__install__os_user('vlagent').with_shell('/bin/bash') }
        end

        context 'with user homedir set' do
          let(:params) { super().merge(homedir: '/srv/vlagent') }

          it { is_expected.to contain_victorialogs__install__os_user('vlagent').with_homedir('/srv/vlagent') }
        end

        context 'with user homedir attributes set' do
          let(:params) { super().merge(homedir_mode: '0751', homedir_owner: 'foo', homedir_group: 'bar') }

          it do
            is_expected.to contain_victorialogs__install__os_user('vlagent')
              .with_homedir_mode('0751')
              .with_homedir_owner('foo')
              .with_homedir_group('bar')
          end
        end

        context 'with instances set' do
          let(:params) do
            super().merge(
              instances: {
                foo: {
                  options: {
                    common: {
                      'remoteWrite.url' => 'http://foo.tld:9428/insert/native',
                    },
                  },
                },
                bar: {
                  options: {
                    common: {
                      'remoteWrite.url' => 'http://bar.tld:9428/insert/native',
                    },
                  },
                },
                baz: {
                  ensure: 'absent',
                },
              },
            )
          end

          it { is_expected.to compile.with_all_deps }

          %w[foo bar].each do |inst|
            it do
              is_expected.to contain_victorialogs__vlagent__instance(inst)
                .with_ensure('present')
                .with_service_name("vlagent-#{inst}")
                .with_options('common' => { 'remoteWrite.url' => "http://#{inst}.tld:9428/insert/native" })
                .that_subscribes_to('Class[Victorialogs::Vlagent::Install]')
                .that_requires('Victorialogs::Install::Os_user[vlagent]')
            end
          end

          it { is_expected.to contain_victorialogs__vlagent__instance('baz').with_ensure('absent') }

          context 'with ensure=>absent' do
            let(:params) { super().merge(ensure: 'absent') }

            it { is_expected.to compile.with_all_deps }

            %w[foo bar baz].each do |inst|
              it do
                is_expected.to contain_victorialogs__vlagent__instance(inst)
                  .with_ensure('absent')
                  .with_service_name("vlagent-#{inst}")
              end
            end
          end
        end

        context 'with download & checksum URLs set' do
          let(:params) do
            super().merge(
              download_url: 'https://example.tld/foo.tar.gz',
              checksum_url: 'https://example.tld/foo-checksums.txt',
            )
          end

          it do
            is_expected.to contain_archive('/tmp/vlagent-1.2.3-oss.tar.gz')
              .with_source('https://example.tld/foo.tar.gz')
              .with_checksum_url('https://example.tld/foo-checksums.txt')
          end
        end

        context 'with binary_path set' do
          let(:params) { super().merge(binary_path: '/opt/bin/vlagent') }

          it do
            is_expected.to contain_file('/opt/bin/vlagent')
              .with_ensure('link')
              .with_target('/opt/vlagent-1.2.3-oss/vlagent-prod')
          end

          it { is_expected.not_to contain_file('/usr/local/bin/vlagent-prod') }
        end

        context 'with ensure=>absent' do
          let(:params) { super().merge(ensure: 'absent') }

          it { is_expected.to compile.with_all_deps }
          it { is_expected.to contain_victorialogs__install__os_user('vlagent').with_ensure('absent') }

          it do
            is_expected.to contain_file('/opt/vlagent-1.2.3-oss')
              .with_ensure('absent')
              .with_recurse(true)
              .with_force(true)
          end

          it { is_expected.not_to contain_archive('/tmp/vlagent-1.2.3-oss.tar.gz') }
          it { is_expected.not_to contain_file('/opt/vlagent-1.2.3-oss/vlagent-prod') }
          it { is_expected.to contain_file('/usr/local/bin/vlagent-prod').with_ensure('absent') }
        end
      end

      context 'with version/edition/install_method inherited from victorialogs class' do
        let(:pre_condition) { 'class { "victorialogs": version => "1.2.3", edition => "enterprise", install_method => "archive" }' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/opt/vlagent-1.2.3-enterprise') }

        it do
          is_expected.to contain_archive('/tmp/vlagent-1.2.3-enterprise.tar.gz')
            .with_source(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise.tar.gz',
            )
        end
      end
    end
  end
end
