# frozen_string_literal: true

require 'fileutils'
require 'json'
require 'net/http'
require 'tmpdir'

IGNORED_OPTIONS = %w[
  version
  eula
].freeze

def fetch_latest_version
  uri = URI('https://api.github.com/repos/VictoriaMetrics/VictoriaLogs/releases/latest')
  response = Net::HTTP.get(uri)
  json = JSON.parse(response)
  json['tag_name'].gsub(%r{^v}, '')
end

def download_file(url, path, max_redirects: 10)
  uri = URI(url)
  redirect_count = 0

  loop do
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')

    request = Net::HTTP::Get.new(uri)
    response = http.request(request)

    unless response.is_a?(Net::HTTPRedirection)
      File.binwrite(path, response.body)
      break
    end

    redirect_count += 1
    raise "Too many redirects (#{redirect_count})" if redirect_count > max_redirects

    uri = URI(response['location'])
  end
end

namespace :victorialogs do
  desc 'Generate types/clioption.pp from VictoriaLogs --help output'
  task :generate_cli_options, [:version] do |_t, args|
    version = args[:version] || fetch_latest_version

    platform = Gem::Platform.local
    os = platform.os
    arch = case platform.cpu
           when 'x86_64' then 'amd64'
           else platform.cpu
           end
    # Download enterprise version to collect enterprise CLI options also
    download_url = "https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v#{version}/victoria-logs-#{os}-#{arch}-v#{version}-enterprise.tar.gz"

    help_output = Dir.mktmpdir do |dir|
      archive_path = File.join(dir, "victoria-logs-#{version}-#{os}-#{arch}.tar.gz")
      puts "Downloading #{download_url}..."
      download_file(download_url, archive_path)

      extract_dir = File.join(dir, "victoria-logs-#{version}-#{os}-#{arch}")
      FileUtils.mkdir_p(extract_dir)
      puts "Extracting #{archive_path}..."
      system('/usr/bin/tar', '-C', extract_dir, '-xzf', archive_path)

      binary_path = File.join(extract_dir, 'victoria-logs-prod')
      puts 'Collecting help output...'
      `#{binary_path} --help 2>&1`
    end

    cli_options = []
    help_output.each_line do |line|
      match = line.match(%r{^\s+-([a-zA-Z][a-zA-Z0-9_.-]+)})
      cli_options << match[1] if match && !IGNORED_OPTIONS.include?(match[1])
    end
    cli_options.uniq.sort

    output_path = File.expand_path('../types/option.pp', __dir__)
    enum_values = cli_options.map { |opt| "  '#{opt}'" }.join(",\n")

    content = <<~CONTENT
      # @summary VictoriaLogs CLI option type
      #
      # @note
      #   This type is generated with `rake victorialogs:generate_cli_options`
      #
      type Victorialogs::Option = Enum[
      #{enum_values},
      ]
    CONTENT
    File.write(output_path, content)

    puts "Generated #{output_path} with #{cli_options.length} CLI options"
  end
end
