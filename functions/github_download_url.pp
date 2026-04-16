# @summary Make a Github release artifact URL for specified version & edition
# @param edition VictoriaLogs edition (OSS/enterprise)
# @param version VictoriaLogs version
# @param download_type Whether to make archive or checksum download URL
# @return [String] Github release download URL
function victorialogs::github_download_url(
  Enum['oss', 'enterprise'] $edition,
  Optional[String[1]] $version,
  Enum['archive', 'checksum'] $download_type,
) >> String[1] {
  $edition_suffix = $edition ? {
    'enterprise' => '-enterprise',
    default      => '',
  }

  $tail = $download_type ? {
    'checksum' => '_checksums.txt',
    default    => '.tar.gz',
  }

  $url = @("URL"/L)
    https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v${version}/\
    victoria-logs-${facts['kernel'].downcase}-${facts['os']['architecture']}-v${version}${$edition_suffix}${tail}
    |-URL

  $url
}
