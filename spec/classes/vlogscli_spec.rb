# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::vlogscli' do
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
        let(:params) { { install_method: 'none', binary_path: '/opt/bin/vlogscli' } }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to have_package_resource_count(0) }
        it { is_expected.to have_archive_resource_count(0) }
      end

      context 'with default install_method (archive) and version set' do
        let(:params) { { version: '1.2.3' } }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_file('/opt/vlogscli-1.2.3-oss')
            .with_ensure('directory')
            .without_recurse
            .without_force
        end

        it do
          is_expected.to contain_archive('/tmp/vlogscli-1.2.3-oss.tar.gz')
            .with_source(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3.tar.gz',
            )
            .with_checksum_url(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3_checksums.txt',
            )
            .with_extract_path('/opt/vlogscli-1.2.3-oss')
            .with_creates('/opt/vlogscli-1.2.3-oss/vlogscli-prod')
            .that_comes_before('File[/opt/vlogscli-1.2.3-oss/vlogscli-prod]')
        end

        it { is_expected.to contain_file('/opt/vlogscli-1.2.3-oss/vlogscli-prod').with_ensure('file') }

        it do
          is_expected.to contain_file('/usr/local/bin/vlogscli')
            .with_ensure('link')
            .with_target('/opt/vlogscli-1.2.3-oss/vlogscli-prod')
        end

        context 'with edition=>enterprise' do
          let(:params) { super().merge(edition: 'enterprise') }

          it { is_expected.to contain_file('/opt/vlogscli-1.2.3-enterprise').with_ensure('directory') }

          it do
            is_expected.to contain_archive('/tmp/vlogscli-1.2.3-enterprise.tar.gz')
              .with_source(
                'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise.tar.gz',
              )
              .with_checksum_url(
                'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise_checksums.txt',
              )
              .with_extract_path('/opt/vlogscli-1.2.3-enterprise')
              .with_creates('/opt/vlogscli-1.2.3-enterprise/vlogscli-prod')
              .that_comes_before('File[/opt/vlogscli-1.2.3-enterprise/vlogscli-prod]')
          end

          it { is_expected.to contain_file('/opt/vlogscli-1.2.3-enterprise/vlogscli-prod').with_ensure('file') }

          it do
            is_expected.to contain_file('/usr/local/bin/vlogscli')
              .with_ensure('link')
              .with_target('/opt/vlogscli-1.2.3-enterprise/vlogscli-prod')
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
            is_expected.to contain_archive('/tmp/vlogscli-1.2.3-oss.tar.gz')
              .with_source('https://example.tld/foo.tar.gz')
              .with_checksum_url('https://example.tld/foo-checksums.txt')
          end
        end

        context 'with binary_path set' do
          let(:params) { super().merge(binary_path: '/opt/bin/vlogscli') }

          it do
            is_expected.to contain_file('/opt/bin/vlogscli')
              .with_ensure('link')
              .with_target('/opt/vlogscli-1.2.3-oss/vlogscli-prod')
          end

          it { is_expected.not_to contain_file('/usr/local/bin/vlogscli') }
        end

        context 'with ensure=>absent' do
          let(:params) { super().merge(ensure: 'absent') }

          it { is_expected.to compile.with_all_deps }

          it do
            is_expected.to contain_file('/opt/vlogscli-1.2.3-oss')
              .with_ensure('absent')
              .with_recurse(true)
              .with_force(true)
          end

          it { is_expected.not_to contain_archive('/tmp/vlogscli-1.2.3-oss.tar.gz') }
          it { is_expected.not_to contain_file('/opt/vlogscli-1.2.3-oss/vlogscli-prod') }
          it { is_expected.to contain_file('/usr/local/bin/vlogscli').with_ensure('absent') }
        end
      end

      context 'with version/edition/install_method inherited from victorialogs class' do
        let(:pre_condition) { 'class { "victorialogs": version => "1.2.3", edition => "enterprise", install_method => "archive" }' }

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/opt/vlogscli-1.2.3-enterprise') }

        it do
          is_expected.to contain_archive('/tmp/vlogscli-1.2.3-enterprise.tar.gz')
            .with_source(
              'https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise.tar.gz',
            )
        end
      end
    end
  end
end
