# @summary Manage vlogscli tool
#
# @example
#   # Install vlogscli from archive:
#
#   class { 'victorialogs::vlogscli':
#     version => '1.52.0',
#   }
#
# @param ensure
#   Whether to install or remove vlogscli.
# @param edition
#   vlogscli edition to install. Defaults to `victorialogs::edition` when set,
#   `oss` otherwise.
# @param install_method
#   How to install vlogscli. Defaults to `victorialogs::install_method` when
#   set, `archive` otherwise.
# @param version
#   The version of vlogscli to install. Required when install_method is
#   'archive' or 'package'. Defaults to `victorialogs::version` when set.
# @param package_name
#   The name of the package to install when using the 'package' install method.
#   Required when install_method is 'package'.
# @param download_url
#   The URL to download vlogscli from. Defaults to GitHub releases based on
#   version and edition.
# @param checksum_url
#   The URL to download the checksum file from. Defaults to GitHub releases
#   based on version and edition.
# @param binary_path
#   Specify where to look for the vlogscli binary. Required when
#   install_method is 'none' or 'package'.
class victorialogs::vlogscli (
  Enum['absent', 'present'] $ensure = 'present',
  Enum['oss', 'enterprise'] $edition = getvar('victorialogs::edition').lest || { 'oss' },
  Enum['archive', 'package', 'none'] $install_method = getvar('victorialogs::install_method').lest || { 'archive' },
  Optional[String[1]] $version = getvar('victorialogs::version'),
  Optional[String[1]] $package_name = undef,
  Optional[Stdlib::HTTPUrl] $download_url = victorialogs::github_download_url('vlutils', $version, $edition, 'archive'),
  Optional[Stdlib::HTTPUrl] $checksum_url = victorialogs::github_download_url('vlutils', $version, $edition, 'checksum'),
  Optional[Stdlib::Absolutepath] $binary_path = undef,
) {
  contain victorialogs::vlogscli::install
}
