# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::install::archive' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:title) { 'victorialogs-1.2.3-oss' }
      let(:params) do
        {
          download_url: 'https://example.tld/foo.tar.gz',
          binary_path: '/usr/local/bin/victoria-logs-prod',
          binary_name: 'victoria-logs-prod',
        }
      end

      context 'with default params' do
        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_file('/opt/victorialogs-1.2.3-oss')
            .with_ensure('directory')
            .with_owner('root')
            .with_group('root')
            .with_mode('0755')
            .without_recurse
            .without_force
        end

        it do
          is_expected.to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz')
            .with_source('https://example.tld/foo.tar.gz')
            .without_checksum_url
            .with_checksum_verify(false)
            .with_extract(true)
            .with_extract_path('/opt/victorialogs-1.2.3-oss')
            .with_extract_flags('tar' => '--no-same-owner --no-same-permissions --no-xattrs --no-acls -xf')
            .with_creates('/opt/victorialogs-1.2.3-oss/victoria-logs-prod')
            .with_cleanup(true)
            .that_comes_before('File[/opt/victorialogs-1.2.3-oss/victoria-logs-prod]')
        end

        it do
          is_expected.to contain_file('/opt/victorialogs-1.2.3-oss/victoria-logs-prod')
            .with_ensure('file')
            .with_owner('root')
            .with_group(0)
            .with_mode('0755')
        end

        it do
          is_expected.to contain_file('/usr/local/bin/victoria-logs-prod')
            .with_ensure('link')
            .with_target('/opt/victorialogs-1.2.3-oss/victoria-logs-prod')
        end
      end

      context 'with checksum_url set' do
        let(:params) { super().merge(checksum_url: 'https://example.tld/foo-checksums.txt') }

        it do
          is_expected.to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz')
            .with_checksum_url('https://example.tld/foo-checksums.txt')
            .with_checksum_verify(true)
        end

        context 'with checksum_verify=false' do
          let(:params) { super().merge(checksum_verify: false) }

          it { is_expected.to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz').with_checksum_verify(false) }
        end
      end

      context 'with tmp_dir set' do
        let(:params) { super().merge(tmp_dir: '/var/tmp') }

        it { is_expected.to contain_archive('/var/tmp/victorialogs-1.2.3-oss.tar.gz') }
      end

      context 'with archive_name set' do
        let(:params) { super().merge(archive_name: 'foo-1.0.0') }

        it { is_expected.to contain_file('/opt/foo-1.0.0').with_ensure('directory') }

        it do
          is_expected.to contain_archive('/tmp/foo-1.0.0.tar.gz')
            .with_extract_path('/opt/foo-1.0.0')
            .with_creates('/opt/foo-1.0.0/victoria-logs-prod')
            .that_comes_before('File[/opt/foo-1.0.0/victoria-logs-prod]')
        end

        it { is_expected.to contain_file('/opt/foo-1.0.0/victoria-logs-prod').with_ensure('file') }

        it do
          is_expected.to contain_file('/usr/local/bin/victoria-logs-prod')
            .with_ensure('link')
            .with_target('/opt/foo-1.0.0/victoria-logs-prod')
        end
      end

      context 'with extract_flags set' do
        let(:params) { super().merge(extract_flags: { 'tar' => '-xf' }) }

        it { is_expected.to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz').with_extract_flags('tar' => '-xf') }
      end

      context 'with binary_name and binary_path set' do
        let(:params) { super().merge(binary_name: 'foo-prod', binary_path: '/opt/bin/foo') }

        it do
          is_expected.to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz')
            .with_creates('/opt/victorialogs-1.2.3-oss/foo-prod')
            .that_comes_before('File[/opt/victorialogs-1.2.3-oss/foo-prod]')
        end

        it { is_expected.to contain_file('/opt/victorialogs-1.2.3-oss/foo-prod').with_ensure('file') }

        it do
          is_expected.to contain_file('/opt/bin/foo')
            .with_ensure('link')
            .with_target('/opt/victorialogs-1.2.3-oss/foo-prod')
        end
      end

      context 'with ensure=>absent' do
        let(:params) { super().merge(ensure: 'absent') }

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_file('/opt/victorialogs-1.2.3-oss')
            .with_ensure('absent')
            .with_recurse(true)
            .with_force(true)
        end

        it { is_expected.not_to contain_archive('/tmp/victorialogs-1.2.3-oss.tar.gz') }
        it { is_expected.not_to contain_file('/opt/victorialogs-1.2.3-oss/victoria-logs-prod') }
        it { is_expected.to contain_file('/usr/local/bin/victoria-logs-prod').with_ensure('absent') }
      end
    end
  end
end
