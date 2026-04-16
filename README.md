# Puppet module to manage VictoriaLogs

## Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Development](#development)

## Description

This module installs and configures [VictoriaLogs](https://victoriametrics.com/products/victorialogs/)

## Usage

### Run a single-node VictoriaLogs

```puppet
include victorialogs
```

### Run a single-node VictoriaLogs of a specific version with 2 syslog inputs

```puppet
class { 'victorialogs':
  version => '1.50.0',
  instances => {
    single => {
      options => {
        'common' => {
          '-storageDataPath' => '/var/lib/victorialogs/data00',
        },
        'syslog-input-1' => {
          '-syslog.listenAddr.tcp' => 'localhost:514',
          '-syslog.tenantID.tcp' => '123:0',
          '-syslog.compressMethod.tcp' => 'gzip',
          '-syslog.tls' => false,
          '-syslog.tlsKeyFile' => '',
          '-syslog.tlsCertFile' => '',
        },
        'syslog-input-2' => {
          '-syslog.listenAddr.tcp' => ':6514',
          '-syslog.tenantID.tcp' => '567:0',
          '-syslog.compressMethod.tcp' => 'none',
          '-syslog.tls' => true,
          '-syslog.tlsKeyFile' => '/path/to/tls/key',
          '-syslog.tlsCertFile' => '/path/to/tls/cert',
        },
      },
    },
  },
}
```

### Same as above, but configured in Hiera

```puppet
include victorialogs
```

```yaml
victorialogs::version: '1.50.0'
victorialogs::instances:
  single:
    options:
      common:
        '-storageDataPath': '/var/lib/victorialogs/data00'
      syslog-input-1:
        '-syslog.listenAddr.tcp': 'localhost:514'
        '-syslog.tenantID.tcp': '123:0'
        '-syslog.compressMethod.tcp': 'gzip'
        '-syslog.tls': false
        '-syslog.tlsKeyFile': ''
        '-syslog.tlsCertFile': ''
      syslog-input-2:
        '-syslog.listenAddr.tcp': ':6514'
        '-syslog.tenantID.tcp': '567:0'
        '-syslog.compressMethod.tcp': 'none'
        '-syslog.tls': true
        '-syslog.tlsKeyFile': '/path/to/tls/key'
        '-syslog.tlsCertFile': '/path/to/tls/cert'
```

## Development

### Regenerating CLI Options Type

The `types/option.pp` file contains an Enum of all VictoriaLogs CLI options. It is auto-generated from the `--help` output of the VictoriaLogs binary.

To regenerate it after a new VictoriaLogs release:

```bash
bundle exec rake victorialogs:generate_cli_options
```

This will:

1. Fetch the latest VictoriaLogs version from GitHub
2. Download and extract the binary
3. Run `victoria-logs-prod --help` and parse the output
4. Generate `types/option.pp` with all CLI options

You can also specify a specific version to use.

```bash
bundle exec rake victorialogs:generate_cli_options[1.49.0]
```

## Reference

See [REFERENCE.md](REFERENCE.md)

## Author

This module is maintained by [Vox Pupuli](https://voxpupuli.org). It was
originally written by [Yury Bushmelev](https://github.com/jay7x)
