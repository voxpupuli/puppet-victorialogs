# @summary Defined resource type to manage a vlagent instance
#
# @note
#   While this defined resource type expects that `victorialogs::vlagent`
#   class is included before, it's possible to use it standalone. It's user's
#   responsibility to specify `user`, `group`, `binary_path` parameters for
#   every instance then.
#
# @example
#   # Forward logs collected to a local VictoriaLogs
#
#   victorialogs::vlagent::instance { 'single':
#     options => {
#       'common' => {
#         'remoteWrite.url' => 'http://localhost:9428/insert/native',
#       },
#     },
#   }
#
# @param ensure
#   Whether to create or remove the vlagent instance.
# @param service_active
#   Whether the vlagent service should be running.
# @param service_enable
#   Whether the vlagent service should be enabled at boot.
# @param service_name
#   The name of the systemd service unit.
# @param user
#   The user to run vlagent as.
# @param group
#   The group to run vlagent as.
# @param binary_path
#   The path to the vlagent binary.
# @param options
#   A hash of vlagent CLI options. Keys are option names, values are
#   option values.
define victorialogs::vlagent::instance (
  Enum['absent', 'present'] $ensure = getvar('victorialogs::vlagent::ensure').lest || { 'present' },
  Boolean $service_active = true,
  Variant[Boolean, Enum['mask']] $service_enable = true,
  String[1] $service_name = "vlagent-${title}",
  String[1] $user = $victorialogs::vlagent::user,
  String[1] $group = $victorialogs::vlagent::group,
  Stdlib::Absolutepath $binary_path = $victorialogs::vlagent::install::binary_path,
  Hash[String[1], Victorialogs::Vlagent::Options] $options = {},
) {
  $remote_write_url_found = $ensure ? {
    'absent' => true,
    default  => $options.any |$_, $v| { $v['remoteWrite.url'] =~ NotUndef },
  }
  unless $remote_write_url_found {
    fail('At least one remoteWrite.url option is required!')
  }

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
    content => epp('victorialogs/systemd.service.epp', {
      description   => "VictoriaLogs vlagent ${name}",
      instance_name => $name,
      service_name  => $service_name,
      user          => $user,
      group         => $group,
      binary_path   => $binary_path,
      args          => $options.values(),
    }),
  }
}
