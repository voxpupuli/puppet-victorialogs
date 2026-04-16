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
#         '-storageDataPath' => '/var/lib/victorialogs/data00',
#       },
#       'syslog-input-1' => {
#         '-syslog.listenAddr.tcp' => 'localhost:514',
#         '-syslog.tenantID.tcp' => '123:0',
#         '-syslog.compressMethod.tcp' => 'gzip',
#         '-syslog.tls' => false,
#         '-syslog.tlsKeyFile' => '',
#         '-syslog.tlsCertFile' => '',
#       },
#       'syslog-input-2' => {
#         '-syslog.listenAddr.tcp' => ':6514',
#         '-syslog.tenantID.tcp' => '567:0',
#         '-syslog.compressMethod.tcp' => 'none',
#         '-syslog.tls' => true,
#         '-syslog.tlsKeyFile' => '/path/to/tls/key',
#         '-syslog.tlsCertFile' => '/path/to/tls/cert',
#       },
#     },
#   }
#
# @param ensure
#   Whether to create or remove the VictoriaLogs instance. Valid values are 'present' and 'absent'.
# @param service_active
#   Whether the VictoriaLogs service should be running.
# @param service_enable
#   Whether the VictoriaLogs service should be enabled at boot. Valid values are true, false, or 'mask'.
# @param service_name
#   The name of the systemd service unit.
# @param user
#   The user to run VictoriaLogs as.
# @param group
#   The group to run VictoriaLogs as.
# @param binary_path
#   The path to the VictoriaLogs binary.
# @param options
#   A hash of VictoriaLogs CLI options. Keys are option names, values are option values.
define victorialogs::instance (
  Enum['absent', 'present'] $ensure = getvar('victorialogs::ensure').lest || { 'present' },
  Boolean $service_active = true,
  Variant[Boolean, Enum['mask']] $service_enable = true,
  String[1] $service_name = "victorialogs-${title}",
  String[1] $user = $victorialogs::user,
  String[1] $group = $victorialogs::group,
  Stdlib::Absolutepath $binary_path = $victorialogs::install::binary_path,
  Hash[String[1], Victorialogs::Options] $options = {},
) {
  $real_service_active = $ensure ? {
    'absent' => false,
    default  => $service_active,
  }

  $real_service_enable = $ensure ? {
    'absent' => false,
    default  => $service_enable,
  }

  systemd::unit_file { "${service_name}.service":
    ensure  => $ensure,
    active  => $real_service_active,
    enable  => $real_service_enable,
    content => epp('victorialogs/victorialogs.service.epp', {
        instance_name => $name,
        service_name  => $service_name,
        user          => $user,
        group         => $group,
        binary_path   => $binary_path,
        args          => $options.values(),
    }),
  }
}
