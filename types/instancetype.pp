# @summary VictoriaLogs instance type
type Victorialogs::InstanceType = Struct[{
    Optional[ensure]         => Enum['absent', 'present'],
    Optional[service_active] => Boolean,
    Optional[service_enable] => Variant[Boolean, Enum['mask']],
    Optional[service_name]   => String[1],
    Optional[user]           => String[1],
    Optional[group]          => String[1],
    Optional[binary_path]    => Stdlib::Absolutepath,
    Optional[options]        => Hash[String[1], Victorialogs::Options],
}]
