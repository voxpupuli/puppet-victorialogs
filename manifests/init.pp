# @summary Main class to manage VictoriaLogs
#
# @example
#   Run a single-node VictoriaLogs:
#
#   class { 'victorialogs':
#     version   => '1.49.0',
#   }
#
# @param ensure
#   Whether to install or remove VictoriaLogs.
# @param edition
#   VictoriaLogs edition to install.
# @param install_method
#   How to install VictoriaLogs.
# @param manage_user
#   Whether to manage the VictoriaLogs user.
# @param user
#   The name of the VictoriaLogs user.
# @param shell
#   The shell for the VictoriaLogs user.
# @param homedir
#   The home directory for the VictoriaLogs user.
# @param manage_homedir
#   Whether to manage the VictoriaLogs home directory.
# @param homedir_mode
#   The file mode for the VictoriaLogs home directory.
# @param homedir_owner
#   The owner of the VictoriaLogs home directory.
# @param homedir_group
#   The group of the VictoriaLogs home directory.
# @param manage_group
#   Whether to manage the VictoriaLogs group.
# @param group
#   The name of the VictoriaLogs group.
# @param version
#   The version of VictoriaLogs to install. Required when install_method is
#   'archive' or 'package'.
# @param package_name
#   The name of the package to install when using the 'package' install method.
# @param download_url
#   The URL to download VictoriaLogs from. Defaults to GitHub releases based on
#   version and edition.
# @param checksum_url
#   The URL to download the checksum file from. Defaults to GitHub releases
#   based on version and edition.
# @param binary_path
#   Specify where to look for the VictoriaLogs binary. Required when
#   install_method is 'none'. Auto-guessed otherwise.
# @param instances
#   A hash of VictoriaLogs instances to manage. Keys are instance names, values
#   are hashes of instance options.
class victorialogs (
  Enum['absent', 'present'] $ensure = 'present',
  Enum['oss', 'enterprise'] $edition = 'oss',
  Enum['archive', 'package', 'none'] $install_method = 'archive',
  Boolean $manage_group = true,
  String[1] $group = 'victorialogs',
  Boolean $manage_user = true,
  String[1] $user = 'victorialogs',
  String[1] $shell = '/usr/sbin/nologin',
  String[1] $homedir = '/var/lib/victorialogs',
  Boolean $manage_homedir = true,
  Stdlib::Filemode $homedir_mode = '0750',
  String[1] $homedir_owner = $user,
  String[1] $homedir_group = $group,
  Optional[String[1]] $version = undef,
  String[1] $package_name = 'victorialogs',
  Stdlib::HTTPUrl $download_url = victorialogs::github_download_url($version, $edition, 'archive'),
  Stdlib::HTTPUrl $checksum_url = victorialogs::github_download_url($version, $edition, 'checksum'),
  Optional[Stdlib::Absolutepath] $binary_path = undef,
  Hash[String[1], Victorialogs::InstanceType] $instances = {
    single => {
      options => {
        common => {
          '-storageDataPath' => '/var/lib/victorialogs/victoria-logs-data',
        },
      },
    },
  },
) {
  $group_res = if $manage_group {
    group { $group:
      ensure => $ensure,
      system => true,
    }
  } else {
    undef
  }

  $user_res = if $manage_user {
    user { $user:
      ensure     => $ensure,
      comment    => 'VictoriaLogs user',
      system     => true,
      gid        => $group,
      shell      => $shell,
      home       => $homedir,
      managehome => false,
      before     => if $ensure == 'absent' { $group_res } else { undef },
    }
  } else {
    undef
  }

  $homedir_res = if $manage_homedir {
    file { $homedir:
      ensure  => stdlib::ensure($ensure, 'directory'),
      mode    => $homedir_mode,
      owner   => $homedir_owner,
      group   => $homedir_group,
      recurse => if $ensure == 'absent' { true } else { undef },
      force   => if $ensure == 'absent' { true } else { undef },
    }
  } else {
    undef
  }

  contain victorialogs::install

  $instance_deps = if $ensure =='absent' {
    {
      before => [$group_res, $user_res, $homedir_res, Class['Victorialogs::Install']],
    }
  } else {
    {
      subscribe => Class['Victorialogs::Install'],
      require   => [$group_res, $user_res, $homedir_res],
    }
  }

  $instances.each |$instance_name, $instance_attrs| {
    victorialogs::instance { $instance_name:
      * => $instance_attrs + $instance_deps,
    }
  }
}
