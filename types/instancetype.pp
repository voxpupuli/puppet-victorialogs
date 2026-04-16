# VictoriaLogs instance type alias
type Victorialogs::InstanceType = Struct[{
    Optional[ensure] => Enum['absent', 'present'],
    Optional[options] => Hash[String[1], Victoralogs::Options],
}]
