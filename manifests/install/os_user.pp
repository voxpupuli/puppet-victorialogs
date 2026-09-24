# @summary Manage OS user for VictoriaLogs and vlagent
# @api private
#
# @param ensure
#   Whether to create or remove the user, group and home directory.
# @param manage_user
#   Whether to manage the user resource.
# @param user
#   The name of the user. Defaults to the resource title.
# @param shell
#   The shell for the user.
# @param homedir
#   The home directory for the user.
# @param comment
#   The comment (GECOS) field for the user.
# @param manage_group
#   Whether to manage the group resource.
# @param group
#   The name of the group. Defaults to the user name.
# @param manage_homedir
#   Whether to manage the home directory.
# @param homedir_mode
#   The file mode for the home directory.
# @param homedir_owner
#   The owner of the home directory.
# @param homedir_group
#   The group of the home directory.
define victorialogs::install::os_user (
  Enum['absent', 'present'] $ensure = 'present',
  Boolean $manage_user = true,
  String[1] $user = $title,
  String[1] $shell = '/usr/sbin/nologin',
  String[1] $homedir = "/var/lib/${user}",
  String[1] $comment = "${capitalize($user)} user",
  Boolean $manage_group = true,
  String[1] $group = $user,
  Boolean $manage_homedir = true,
  Stdlib::Filemode $homedir_mode = '0750',
  String[1] $homedir_owner = $user,
  String[1] $homedir_group = $group,
) {
  $group_res = if $manage_group {
    group { $group:
      ensure => $ensure,
      system => true,
    }
  } else {
    undef
  }

  if $manage_user {
    user { $user:
      ensure     => $ensure,
      comment    => $comment,
      system     => true,
      gid        => $group,
      shell      => $shell,
      home       => $homedir,
      managehome => false,
      before     => if $ensure == 'absent' { $group_res } else { undef },
    }
  }

  if $manage_homedir {
    file { $homedir:
      ensure  => stdlib::ensure($ensure, 'directory'),
      mode    => $homedir_mode,
      owner   => $homedir_owner,
      group   => $homedir_group,
      recurse => if $ensure == 'absent' { true } else { undef },
      force   => if $ensure == 'absent' { true } else { undef },
    }
  }
}
