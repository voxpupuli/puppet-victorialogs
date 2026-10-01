# @summary Defined resource type to manage a VictoriaLogs instance
#
# @note
#   While this defined resource type expects that `victorialogs` class is
#   included before, it's possible to use it standalone. It's user's
#   responsibility to specify `user`, `group`, `binary_path` parameters for
#   every instance then.
#
# @example
#   Manage a single-node installation with 2 syslog inputs
#
#   victorialogs::instance { 'single':
#     options => {
#       'common' => {
#         'storageDataPath' => '/var/lib/victorialogs/data00',
#       },
#       'syslog-input-1' => {
#         'syslog.listenAddr.tcp' => 'localhost:514',
#         'syslog.tenantID.tcp' => '123:0',
#         'syslog.compressMethod.tcp' => 'gzip',
#         'syslog.tls' => false,
#         'syslog.tlsKeyFile' => '',
#         'syslog.tlsCertFile' => '',
#       },
#       'syslog-input-2' => {
#         'syslog.listenAddr.tcp' => ':6514',
#         'syslog.tenantID.tcp' => '567:0',
#         'syslog.compressMethod.tcp' => 'none',
#         'syslog.tls' => true,
#         'syslog.tlsKeyFile' => '/path/to/tls/key',
#         'syslog.tlsCertFile' => '/path/to/tls/cert',
#       },
#     },
#   }
#
# @param ensure
#   Whether to create or remove the VictoriaLogs instance.
# @param service_active
#   Whether the VictoriaLogs service should be running.
# @param service_enable
#   Whether the VictoriaLogs service should be enabled at boot.
# @param service_name
#   The name of the systemd service unit.
# @param user
#   The user to run VictoriaLogs as.
# @param group
#   The group to run VictoriaLogs as.
# @param working_directory
#   The working directory for the VictoriaLogs service.
# @param binary_path
#   The path to the VictoriaLogs binary.
# @param options
#   A hash of VictoriaLogs CLI options, grouped into arbitrarily named
#   sections (e.g. `common`, `syslog-input-1`). Section values are hashes
#   of option names to option values. All sections are merged and rendered
#   as `-key=value` command-line arguments, so section names are only
#   organizational and have no effect on the resulting service.
define victorialogs::instance (
  Enum['absent', 'present'] $ensure = getvar('victorialogs::ensure').lest || { 'present' },
  Boolean $service_active = true,
  Variant[Boolean, Enum['mask']] $service_enable = true,
  String[1] $service_name = "victorialogs-${title}",
  Optional[String[1]] $user = getvar('victorialogs::user'),
  Optional[String[1]] $group = getvar('victorialogs::group'),
  Optional[Stdlib::Absolutepath] $working_directory = getvar('victorialogs::homedir'),
  Optional[Stdlib::Absolutepath] $binary_path = getvar('victorialogs::install::binary_path'),
  Hash[String[1], Victorialogs::Options] $options = {},
) {
  if $ensure == 'present' {
    unless $user {
      fail('$user is required when $ensure is "present"')
    }
    unless $group {
      fail('$group is required when $ensure is "present"')
    }
    unless $binary_path {
      fail('$binary_path is required when $ensure is "present"')
    }

    $real_service_active = $service_active
    $real_service_enable = $service_enable
    $real_content = epp('victorialogs/systemd.service.epp', {
      description       => "VictoriaLogs ${name}",
      instance_name     => $name,
      service_name      => $service_name,
      user              => $user,
      group             => $group,
      working_directory => $working_directory,
      binary_path       => $binary_path,
      args              => $options.values(),
    })
  } else {
    $real_service_active = false
    $real_service_enable = false
    $real_content = undef
  }

  systemd::unit_file { "${service_name}.service":
    ensure  => $ensure,
    active  => $real_service_active,
    enable  => $real_service_enable,
    content => $real_content,
  }
}
