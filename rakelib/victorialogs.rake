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

def platform_os_arch
  platform = Gem::Platform.local
  arch = case platform.cpu
         when 'x86_64' then 'amd64'
         else platform.cpu
         end
  [platform.os, arch]
end

def collect_help_output(download_url, archive_basename, binary_name)
  Dir.mktmpdir do |dir|
    archive_path = File.join(dir, "#{archive_basename}.tar.gz")
    puts "Downloading #{download_url}..."
    download_file(download_url, archive_path)

    extract_dir = File.join(dir, archive_basename)
    FileUtils.mkdir_p(extract_dir)
    puts "Extracting #{archive_path}..."
    system('/usr/bin/tar', '-C', extract_dir, '-xzf', archive_path)

    binary_path = File.join(extract_dir, binary_name)
    puts 'Collecting help output...'
    `#{binary_path} --help 2>&1`
  end
end

def parse_cli_options(help_output)
  cli_options = []
  help_output.each_line do |line|
    match = line.match(%r{^\s+-([a-zA-Z][a-zA-Z0-9_.-]+)})
    cli_options << match[1] if match && !IGNORED_OPTIONS.include?(match[1])
  end
  cli_options.uniq.sort
end

def write_option_type(output_path, heading, type_name, cli_options)
  enum_values = cli_options.map { |opt| "  '#{opt}'" }.join(",\n")

  content = <<~CONTENT
    #{heading}
    type #{type_name} = Enum[
    #{enum_values},
    ]
  CONTENT
  File.write(output_path, content)

  puts "Generated #{output_path} with #{cli_options.length} CLI options"
end

def generate_cli_options(binary_name, version = nil, archive_prefix:, output:, type_name:, type_summary:, rake_task:)
  version ||= fetch_latest_version
  puts "Generating CLI options for #{binary_name} v#{version}..."
  os, arch = platform_os_arch

  # Download enterprise version to collect enterprise CLI options also
  download_url = "https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v#{version}/#{archive_prefix}-#{os}-#{arch}-v#{version}-enterprise.tar.gz"
  archive_basename = "#{archive_prefix}-#{version}-#{os}-#{arch}"

  help_output = collect_help_output(download_url, archive_basename, binary_name)
  cli_options = parse_cli_options(help_output)

  header_text = <<~HEADER.chomp
    # @summary #{type_summary}
    #
    # @note
    #   This type is generated from #{binary_name} v#{version} help output
    #   using `rake #{rake_task}`
    #
  HEADER
  output_path = File.expand_path(output, __dir__)
  write_option_type(output_path, header_text, type_name, cli_options)
end

namespace :victorialogs do
  desc 'Generate types/option.pp from VictoriaLogs --help output'
  task :generate_cli_options, [:version] do |_t, args|
    generate_cli_options(
      'victoria-logs-prod',
      args[:version],
      archive_prefix: 'victoria-logs',
      output: '../types/option.pp',
      type_name: 'Victorialogs::Option',
      type_summary: 'VictoriaLogs CLI option type',
      rake_task: 'victorialogs:generate_cli_options',
    )
  end
end

namespace :vlagent do
  desc 'Generate types/vlagent/option.pp from VictoriaLogs vlagent --help output'
  task :generate_cli_options, [:version] do |_t, args|
    generate_cli_options(
      'vlagent-prod',
      args[:version],
      archive_prefix: 'vlutils',
      output: '../types/vlagent/option.pp',
      type_name: 'Victorialogs::Vlagent::Option',
      type_summary: 'VictoriaLogs vlagent CLI option type',
      rake_task: 'vlagent:generate_cli_options',
    )
  end
end
