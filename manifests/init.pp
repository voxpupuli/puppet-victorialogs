# @summary Main class to manage VictoriaLogs
#
# @param ensure
# @param edition
# @param install_method
# @param manage_user
# @param user
# @param shell
# @param homedir
# @param homedir_mode
# @param homedir_owner
# @param homedir_group
# @param manage_homedir
# @param manage_group
# @param group
# @param version
# @param package_name
# @param download_url
# @param checksum_url
# @param instances
class victorialogs (
  Enum['absent', 'present'] $ensure = 'present',
  Enum['oss', 'enterprise'] $edition = 'oss',
  Enum['archive', 'package', 'none'] $install_method = 'archive',
  Boolean $manage_user = true,
  String[1] $user = 'victorialogs',
  String[1] $shell = '/usr/sbin/nologin',
  String[1] $homedir = '/var/lib/victorialogs',
  Stdlib::Filemode $homedir_mode = '0750',
  Stdlib::Filemode $homedir_owner = $user,
  Stdlib::Filemode $homedir_group = $group,
  Boolean $manage_homedir = true,
  Boolean $manage_group = true,
  String[1] $group = 'victorialogs',
  Optional[String[1]] $version = undef,
  String[1] $package_name = 'victorialogs',
  Stdlib::HTTPUrl $download_url = victorialogs::github_download_url($version, $edition, 'archive'),
  Stdlib::HTTPUrl $checksum_url = victorialogs::github_download_url($version, $edition, 'checksum'),
  Hash[String[1], Victoralogs::InstanceType] $instances = {
    single => {
      options => {
        common => {
          '-storageDataPath' => '/var/lib/victorialogs/victoria-logs-data',
        },
      },
    },
  },
) {
  if $manage_group {
    group { $group:
      ensure => $ensure,
      system => true,
    }
  }

  if $manage_user {
    user { $user:
      ensure     => $ensure,
      comment    => 'VictoriaLogs user',
      system     => true,
      gid        => $group,
      shell      => $shell,
      home       => $homedir,
      managehome => false,
    }
  }

  if $manage_homedir {
    # TODO: If $ensure == 'absent', shall we delete it recursively or do nothing?
    file { $homedir:
      ensure => stdlib::ensure($ensure, 'directory'),
      mode   => $homedir_mode,
      owner  => $homedir_owner,
      group  => $homedir_group,
    }
  }

  contain victorialogs::install

  $instances.each |$instance_name, $instance_attrs| {
    victorialogs::instance { $instance_name:
      * => $instance_attrs,
    }
  }
}
