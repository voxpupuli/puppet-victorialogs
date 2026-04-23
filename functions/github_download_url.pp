# @summary Make a Github release artifact URL for specified version & edition
# @param version
#   VictoriaLogs version.
# @param edition
#   VictoriaLogs edition (OSS/enterprise).
# @param download_type
#   Whether to make archive or checksum download URL.
# @return [Optional[String[1]]]
#   Returns Github artifact download URL if version is specified. Returns undef
#   otherwise.
function victorialogs::github_download_url(
  Optional[String[1]] $version,
  Enum['oss', 'enterprise'] $edition,
  Enum['archive', 'checksum'] $download_type,
) >> Optional[String[1]] {
  # This is mostly to avoid exceptions when $victorialogs::install_method != 'archive'.
  unless $version {
    return undef
  }

  $edition_suffix = $edition ? {
    'enterprise' => '-enterprise',
    default      => '',
  }

  $tail = $download_type ? {
    'checksum' => '_checksums.txt',
    default    => '.tar.gz',
  }

  $arch = $facts['os']['hardware'] ? {
    'x86_64' => 'amd64',
    default  => $facts['os']['hardware'],
  }

  $url = @("URL"/L)
    https://github.com/VictoriaMetrics/VictoriaLogs/releases/download/v${version}/\
    victoria-logs-${facts['kernel'].downcase}-${arch}-v${version}${$edition_suffix}${tail}
    |-URL

  $url
}
