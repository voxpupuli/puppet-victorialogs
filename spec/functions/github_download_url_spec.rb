# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::github_download_url' do
  describe 'victoria-logs component' do
    it { is_expected.to run.with_params('victoria-logs', nil, 'oss', 'archive').and_return(nil) }

    context 'with Linux/x86_64' do
      let(:facts) do
        {
          os: { hardware: 'x86_64' },
          kernel: 'Linux',
        }
      end

      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'oss', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3.tar.gz') }
      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'oss', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3_checksums.txt') }
      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'enterprise', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3-enterprise.tar.gz') }
      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'enterprise', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3-enterprise_checksums.txt') }
    end

    context 'with MacOS/arm64' do
      let(:facts) do
        {
          os: { hardware: 'arm64' },
          kernel: 'Darwin',
        }
      end

      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'oss', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-darwin-arm64-v1.2.3.tar.gz') }
      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'oss', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-darwin-arm64-v1.2.3_checksums.txt') }
      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'enterprise', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-darwin-arm64-v1.2.3-enterprise.tar.gz') }
      it { is_expected.to run.with_params('victoria-logs', '1.2.3', 'enterprise', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-darwin-arm64-v1.2.3-enterprise_checksums.txt') }
    end
  end

  describe 'vlutils component' do
    it { is_expected.to run.with_params('vlutils', nil, 'oss', 'archive').and_return(nil) }

    context 'with Linux/x86_64' do
      let(:facts) do
        {
          os: { hardware: 'x86_64' },
          kernel: 'Linux',
        }
      end

      it { is_expected.to run.with_params('vlutils', '1.2.3', 'oss', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3.tar.gz') }
      it { is_expected.to run.with_params('vlutils', '1.2.3', 'oss', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3_checksums.txt') }
      it { is_expected.to run.with_params('vlutils', '1.2.3', 'enterprise', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise.tar.gz') }
      it { is_expected.to run.with_params('vlutils', '1.2.3', 'enterprise', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-linux-amd64-v1.2.3-enterprise_checksums.txt') }
    end

    context 'with MacOS/arm64' do
      let(:facts) do
        {
          os: { hardware: 'arm64' },
          kernel: 'Darwin',
        }
      end

      it { is_expected.to run.with_params('vlutils', '1.2.3', 'oss', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-darwin-arm64-v1.2.3.tar.gz') }
      it { is_expected.to run.with_params('vlutils', '1.2.3', 'oss', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-darwin-arm64-v1.2.3_checksums.txt') }
      it { is_expected.to run.with_params('vlutils', '1.2.3', 'enterprise', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-darwin-arm64-v1.2.3-enterprise.tar.gz') }
      it { is_expected.to run.with_params('vlutils', '1.2.3', 'enterprise', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/vlutils-darwin-arm64-v1.2.3-enterprise_checksums.txt') }
    end
  end
end
