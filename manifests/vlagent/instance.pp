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
# @param working_directory
#   The working directory for the vlagent service.
# @param binary_path
#   The path to the vlagent binary.
# @param options
#   A hash of vlagent CLI options, grouped into arbitrarily named sections
#   (e.g. `common`). Section values are hashes of option names to option
#   values. All sections are merged and rendered as `-key=value`
#   command-line arguments, so section names are only organizational and
#   have no effect on the resulting service. At least one section must
#   define the `remoteWrite.url` option.
define victorialogs::vlagent::instance (
  Enum['absent', 'present'] $ensure = getvar('victorialogs::vlagent::ensure').lest || { 'present' },
  Boolean $service_active = true,
  Variant[Boolean, Enum['mask']] $service_enable = true,
  String[1] $service_name = "vlagent-${title}",
  Optional[String[1]] $user = getvar('victorialogs::vlagent::user'),
  Optional[String[1]] $group = getvar('victorialogs::vlagent::group'),
  Optional[Stdlib::Absolutepath] $working_directory = getvar('victorialogs::vlagent::homedir'),
  Optional[Stdlib::Absolutepath] $binary_path = getvar('victorialogs::vlagent::install::binary_path'),
  Hash[String[1], Victorialogs::Vlagent::Options] $options = {},
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

    # Check if any remoteWrite.url option is defined
    unless $options.any |$_, $v| { $v['remoteWrite.url'] =~ NotUndef } {
      fail('At least one remoteWrite.url option is required!')
    }

    $real_service_active = $service_active
    $real_service_enable = $service_enable
    $real_content = epp('victorialogs/systemd.service.epp', {
      description       => "VictoriaLogs vlagent ${name}",
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
