# @summary VictoriaLogs installation class
# @api private
#
# @param tmp_dir
#   The temporary directory used for downloading and extracting the archive.
#   The only purpose of this parameter is to allow to set it from Hiera if /tmp
#   doesn't fit your needs.
class victorialogs::install (
  Stdlib::Absolutepath $tmp_dir = '/tmp', # It's up to user to ensure this directory exists
) {
  assert_private()

  case $victorialogs::install_method {
    'archive': {
      unless $victorialogs::version {
        fail('$version is required when $install_method is "archive"!')
      }

      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::binary_path.lest || { '/usr/local/bin/victoria-logs-prod' }

      victorialogs::install::archive { "victorialogs-${victorialogs::version}-${victorialogs::edition}":
        ensure       => $victorialogs::ensure,
        download_url => $victorialogs::download_url,
        checksum_url => $victorialogs::checksum_url,
        binary_path  => $binary_path,
        binary_name  => 'victoria-logs-prod',
        tmp_dir      => $tmp_dir,
      }
    }
    'package': {
      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::binary_path

      $package_ensure = $victorialogs::ensure ? {
        'absent' => 'absent',
        default  => $victorialogs::version.then |$x| { $x }.lest || { 'installed' }
      }
      package { $victorialogs::package_name:
        ensure => $package_ensure,
      }
    }
    default: {
      # It's up to user to point to the VictoriaLogs binary then
      $binary_path = $victorialogs::binary_path
    }
  }
}
