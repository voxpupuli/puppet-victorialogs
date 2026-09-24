# @summary Manage vlagent
#
# @example
#   # Forward logs to a local VictoriaLogs:
#
#   class { 'victorialogs::vlagent':
#     version   => '1.52.0',
#     instances => {
#       single => {
#         options => {
#           common => {
#             'remoteWrite.url' => 'http://localhost:9428/insert/native',
#           },
#         },
#       },
#     },
#   }
#
# @param ensure
#   Whether to install or remove vlagent.
# @param edition
#   vlagent edition to install. Defaults to `victorialogs::edition` when set,
#   `oss` otherwise.
# @param install_method
#   How to install vlagent. Defaults to `victorialogs::install_method` when
#   set, `archive` otherwise.
# @param manage_user
#   Whether to manage the vlagent user.
# @param manage_group
#   Whether to manage the vlagent group.
# @param manage_homedir
#   Whether to manage the vlagent home directory.
# @param group
#   The name of the vlagent group.
# @param user
#   The name of the vlagent user.
# @param shell
#   The shell for the vlagent user.
# @param homedir
#   The home directory for the vlagent user.
# @param homedir_mode
#   The file mode for the vlagent home directory.
# @param homedir_owner
#   The owner of the vlagent home directory.
# @param homedir_group
#   The group of the vlagent home directory.
# @param version
#   The version of vlagent to install. Required when install_method is
#   'archive' or 'package'. Defaults to `victorialogs::version` when set.
# @param package_name
#   The name of the package to install when using the 'package' install method.
#   Required when install_method is 'package'.
# @param download_url
#   The URL to download vlagent from. Defaults to GitHub releases based on
#   version and edition.
# @param checksum_url
#   The URL to download the checksum file from. Defaults to GitHub releases
#   based on version and edition.
# @param binary_path
#   Specify where to look for the vlagent binary. Required when
#   install_method is 'none' or 'package'.
# @param instances
#   A hash of vlagent instances to manage. Keys are instance names, values
#   are hashes of instance options.
class victorialogs::vlagent (
  Enum['absent', 'present'] $ensure = 'present',
  Enum['oss', 'enterprise'] $edition = getvar('victorialogs::edition').lest || { 'oss' },
  Enum['archive', 'package', 'none'] $install_method = getvar('victorialogs::install_method').lest || { 'archive' },
  Boolean $manage_user = true,
  Boolean $manage_group = $manage_user,
  Boolean $manage_homedir = $manage_user,
  String[1] $group = 'vlagent',
  String[1] $user = 'vlagent',
  String[1] $shell = '/usr/sbin/nologin',
  String[1] $homedir = "/var/lib/${user}",
  Stdlib::Filemode $homedir_mode = '0750',
  String[1] $homedir_owner = $user,
  String[1] $homedir_group = $group,
  Optional[String[1]] $version = getvar('victorialogs::version'),
  Optional[String[1]] $package_name = undef,
  Optional[Stdlib::HTTPUrl] $download_url = victorialogs::github_download_url('vlutils', $version, $edition, 'archive'),
  Optional[Stdlib::HTTPUrl] $checksum_url = victorialogs::github_download_url('vlutils', $version, $edition, 'checksum'),
  Optional[Stdlib::Absolutepath] $binary_path = undef,
  Hash[String[1], Victorialogs::Vlagent::InstanceType] $instances = {},
) {
  victorialogs::install::os_user { $user:
    ensure         => $ensure,
    manage_group   => $manage_group,
    group          => $group,
    manage_user    => $manage_user,
    user           => $user,
    shell          => $shell,
    homedir        => $homedir,
    manage_homedir => $manage_homedir,
    homedir_mode   => $homedir_mode,
    homedir_owner  => $homedir_owner,
    homedir_group  => $homedir_group,
  }

  contain victorialogs::vlagent::install

  $instance_deps = if $ensure == 'absent' {
    {
      before => [
        Victorialogs::Install::Os_user[$user],
        Class['Victorialogs::Vlagent::Install'],
      ],
    }
  } else {
    {
      require   => Victorialogs::Install::Os_user[$user],
      subscribe => Class['Victorialogs::Vlagent::Install'],
    }
  }

  $instances.each |$instance_name, $instance_attrs| {
    victorialogs::vlagent::instance { $instance_name:
      * => $instance_attrs + $instance_deps,
    }
  }
}
