# @summary Manage a binary installation from a release archive
# @api private
#
# Shared implementation behind `victorialogs::install`,
# `victorialogs::vlagent::install` and `victorialogs::vlogscli::install`.
# Downloads the tarball, extracts it to `/opt/<archive name>` and symlinks it
# to `$binary_path`.
#
# @param download_url
#   The URL to download the archive from.
# @param binary_path
#   Where to place the symlink pointing at the extracted binary.
# @param binary_name
#   The file name of the binary inside the archive (e.g. `vlagent-prod`).
# @param ensure
#   Whether to install or remove the binary.
# @param checksum_url
#   The URL to download the checksum file from.
# @param archive_name
#   The base name of the archive (without `.tar.gz`). Defaults to the resource
#   title. Used for the install directory (`/opt/<archive name>`) and the
#   downloaded file (`<tmp dir>/<archive name>.tar.gz`).
# @param tmp_dir
#   The temporary directory used for downloading the archive. It's up to user
#   to ensure this directory exists.
define victorialogs::install::archive (
  Stdlib::HTTPUrl $download_url,
  Stdlib::Absolutepath $binary_path,
  String[1] $binary_name,
  Enum['absent', 'present'] $ensure = 'present',
  Optional[Stdlib::HTTPUrl] $checksum_url = undef,
  String[1] $archive_name = $title,
  Stdlib::Absolutepath $tmp_dir = '/tmp',
) {
  $install_dir = "/opt/${archive_name}"
  $extracted_binary = "${install_dir}/${binary_name}"

  file { $install_dir:
    ensure  => stdlib::ensure($ensure, 'directory'),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => if $ensure == 'absent' { true } else { undef },
    force   => if $ensure == 'absent' { true } else { undef },
  }

  unless $ensure == 'absent' {
    archive { "${tmp_dir}/${archive_name}.tar.gz":
      source       => $download_url,
      checksum_url => $checksum_url,
      extract      => true,
      extract_path => $install_dir,
      creates      => $extracted_binary,
      cleanup      => true,
      before       => File[$extracted_binary],
    }

    file { $extracted_binary:
      ensure => 'file',
      owner  => 'root',
      group  => 0, # Workaround for MacOS/*BSD (those uses 'wheel' group)
      mode   => '0755',
    }
  }

  file { $binary_path:
    ensure => stdlib::ensure($ensure, 'link'),
    target => $extracted_binary,
  }
}
