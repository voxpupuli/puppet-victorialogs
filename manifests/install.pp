# @summary VictoriaLogs installation class
# @api private
class victorialogs::install (
  Stdlib::Absolutepath $archive_binary = '/usr/local/bin/victoria-logs-prod',
  Stdlib::Absolutepath $package_binary = '/usr/bin/victoria-logs-prod',
  Stdlib::Absolutepath $install_dir = "/opt/victorialogs-${victorialogs::version}-${victorialogs::edition}",
  Stdlib::Absolutepath $tmp_dir = '/tmp', # It's up to user to ensure this directory exists

) {
  assert_private()

  case $victorialogs::install_method {
    'archive': {
      # This variable is used outside of this class to find the binary
      # irregardless of the install_method
      $binary_path = $archive_binary

      unless $victorialogs::version {
        fail('$version is required when $install_method is "archive"!')
      }

      $extracted_binary = "${install_dir}/victoria-logs-prod"

      file { $install_dir:
        ensure => stdlib::ensure($victorialogs::ensure, 'directory'),
        owner  => 'root',
        group  => 'root',
        mode   => '0755',
      }

      archive { "${tmp_dir}/${victorialogs::version}-${victorialogs::edition}.tar.gz":
        ensure       => $victorialogs::ensure,
        source       => $victorialogs::download_url,
        checksum_url => $victorialogs::checksum_url,
        extract      => true,
        extract_path => $install_dir,
        creates      => $extracted_binary,
        cleanup      => true,
        before       => File[$extracted_binary],
      }

      file { $extracted_binary:
        ensure => stdlib::ensure($victorialogs::ensure, 'file'),
        owner  => 'root',
        group  => 0, # Workaround for MacOS/*BSD (those uses 'wheel' group)
        mode   => '0755',
      }

      file { $binary_path:
        ensure => stdlib::ensure($victorialogs::ensure, 'link'),
        target => $extracted_binary,
      }
    }
    'package': {
      # This variable is used outside of this class to find the binary
      # irregardless of the install_method
      $binary_path = $package_binary

      $package_ensure = $victorialogs::ensure ? {
        'absent' => 'absent',
        default  => $victorialogs::version.then |$x| { $x }.lest || { 'installed' }
      }
      package { $victorialogs::package_name:
        ensure => $package_ensure,
      }
    }
    default: {
      # Do nothing
    }
  }
}
