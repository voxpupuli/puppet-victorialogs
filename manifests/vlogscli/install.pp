# @summary VictoriaLogs vlogscli installation class
# @api private
#
# @param tmp_dir
#   The temporary directory used for downloading and extracting the archive.
#   The only purpose of this parameter is to allow to set it from Hiera if /tmp
#   doesn't fit your needs. It's up to user to ensure this directory exists
class victorialogs::vlogscli::install (
  Stdlib::Absolutepath $tmp_dir = '/tmp',
) {
  assert_private()

  case $victorialogs::vlogscli::install_method {
    'archive': {
      unless $victorialogs::vlogscli::version {
        fail('$version is required when $install_method is "archive"!')
      }

      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::vlogscli::binary_path.lest || { '/usr/local/bin/vlogscli' }

      victorialogs::install::archive { "vlogscli-${victorialogs::vlogscli::version}-${victorialogs::vlogscli::edition}":
        ensure       => $victorialogs::vlogscli::ensure,
        download_url => $victorialogs::vlogscli::download_url,
        checksum_url => $victorialogs::vlogscli::checksum_url,
        binary_path  => $binary_path,
        binary_name  => 'vlogscli-prod',
        tmp_dir      => $tmp_dir,
      }
    }
    'package': {
      unless $victorialogs::vlogscli::package_name {
        fail('$package_name is required when $install_method is "package"!')
      }

      $package_ensure = $victorialogs::vlogscli::ensure ? {
        'absent' => 'absent',
        default  => $victorialogs::vlogscli::version.lest || { 'installed' }
      }
      package { $victorialogs::vlogscli::package_name:
        ensure => $package_ensure,
      }
      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::vlogscli::binary_path
    }
    default: {
      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::vlogscli::binary_path
    }
  }
}
