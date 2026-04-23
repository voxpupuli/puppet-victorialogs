# frozen_string_literal: true

require 'spec_helper'

describe 'victorialogs::github_download_url' do
  context 'with x86_64 hardware and Linux kernel' do
    let(:facts) do
      {
        os: { hardware: 'x86_64' },
        kernel: 'Linux',
      }
    end

    it { is_expected.to run.with_params(nil, 'oss', 'archive').and_return(nil) }
    it { is_expected.to run.with_params('1.2.3', 'oss', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3.tar.gz') }
    it { is_expected.to run.with_params('1.2.3', 'oss', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3_checksums.txt') }
    it { is_expected.to run.with_params('1.2.3', 'enterprise', 'archive').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3-enterprise.tar.gz') }
    it { is_expected.to run.with_params('1.2.3', 'enterprise', 'checksum').and_return('https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v1.2.3/victoria-logs-linux-amd64-v1.2.3-enterprise_checksums.txt') }
  end
end
