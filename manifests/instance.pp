# @summary Defined resource type to manage a VictoriaLogs instance
#
# @example
#   Manage a single-node installation with 2 syslog inputs
#
#   victorialogs::instance { 'single':
#     options => {
#       'common' => {
#         '-storageDataPath' => '/var/lib/victorialogs/data00',
#       }
#       'syslog-input-1' => {
#         '-syslog.listenAddr.tcp' => 'localhost:514',
#         '-syslog.tenantID.tcp' => '123:0',
#         '-syslog.compressMethod.tcp' => 'gzip',
#         '-syslog.tls' => false,
#         '-syslog.tlsKeyFile' => '',
#         '-syslog.tlsCertFile' => '',
#       }
#       'syslog-input-2' => {
#         '-syslog.listenAddr.tcp' => ':6514',
#         '-syslog.tenantID.tcp' => '567:0',
#         '-syslog.compressMethod.tcp' => 'none',
#         '-syslog.tls' => true,
#         '-syslog.tlsKeyFile' => '/path/to/tls/key',
#         '-syslog.tlsCertFile' => '/path/to/tls/cert',
#       }
#     }
#   }
#
# @param ensure
# @param service_active
# @param service_enable
# @param service_name
# @param user
# @param group
# @param binary_path
# @param options
define victorialogs::instance (
  Enum['absent', 'present'] $ensure = 'present',
  Boolean $service_active = true,
  Variant[Boolean, Enum['mask']] $service_enable = true,
  String[1] $service_name = "victorialogs-${title}",
  String[1] $user = $victorialogs::user,
  String[1] $group = $victorialogs::group,
  Stdlib::Absolutepath $binary_path = $victorialogs::install::binary_path,
  Hash[String[1], Victoralogs::Options] $options = {},
) {
  $real_service_active = $ensure ? {
    'absent' => false,
    default  => $service_active,
  }

  $real_service_enable = $ensure ? {
    'absent' => false,
    default  => $service_enable,
  }

  systemd::unit_file { $service_name:
    ensure    => $ensure,
    active    => $real_service_active,
    enable    => $real_service_enable,
    content   => epp('victorialogs/victorialogs.service.epp', {
        service_name => $service_name,
        user         => $user,
        group        => $group,
        binary_path  => $binary_path,
        args         => $options.values().flatten(),
    }),
    # Restart on VictoriaLogs binary change (upgrade e.g.)
    subscribe => File[$binary_path],
  }
}
