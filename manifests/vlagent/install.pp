# @summary VictoriaLogs vlagent installation class
# @api private
#
# @param tmp_dir
#   The temporary directory used for downloading and extracting the archive.
#   The only purpose of this parameter is to allow to set it from Hiera if /tmp
#   doesn't fit your needs. It's up to user to ensure this directory exists
class victorialogs::vlagent::install (
  Stdlib::Absolutepath $tmp_dir = '/tmp',
) {
  assert_private()

  case $victorialogs::vlagent::install_method {
    'archive': {
      unless $victorialogs::vlagent::version {
        fail('$version is required when $install_method is "archive"!')
      }

      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::vlagent::binary_path.lest || { '/usr/local/bin/vlagent-prod' }

      victorialogs::install::archive { "vlagent-${victorialogs::vlagent::version}-${victorialogs::vlagent::edition}":
        ensure       => $victorialogs::vlagent::ensure,
        download_url => $victorialogs::vlagent::download_url,
        checksum_url => $victorialogs::vlagent::checksum_url,
        binary_path  => $binary_path,
        binary_name  => 'vlagent-prod',
        tmp_dir      => $tmp_dir,
      }
    }
    'package': {
      unless $victorialogs::vlagent::package_name {
        fail('$package_name is required when $install_method is "package"!')
      }

      $package_ensure = $victorialogs::vlagent::ensure ? {
        'absent' => 'absent',
        default  => $victorialogs::vlagent::version.lest || { 'installed' }
      }
      package { $victorialogs::vlagent::package_name:
        ensure => $package_ensure,
      }
      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::vlagent::binary_path
    }
    default: {
      # This variable is used outside of this class to find the binary
      $binary_path = $victorialogs::vlagent::binary_path
    }
  }
}
