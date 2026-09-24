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
          'storageDataPath' => '/var/lib/victorialogs/data00',
        },
        'syslog-input-1' => {
          'syslog.listenAddr.tcp' => 'localhost:514',
          'syslog.tenantID.tcp' => '123:0',
          'syslog.compressMethod.tcp' => 'gzip',
          'syslog.tls' => false,
          'syslog.tlsKeyFile' => '',
          'syslog.tlsCertFile' => '',
        },
        'syslog-input-2' => {
          'syslog.listenAddr.tcp' => ':6514',
          'syslog.tenantID.tcp' => '567:0',
          'syslog.compressMethod.tcp' => 'none',
          'syslog.tls' => true,
          'syslog.tlsKeyFile' => '/path/to/tls/key',
          'syslog.tlsCertFile' => '/path/to/tls/cert',
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
victorialogs::version: "1.50.0"
victorialogs::instances:
  single:
    options:
      common:
        "storageDataPath": "/var/lib/victorialogs/data00"
      syslog-input-1:
        "syslog.listenAddr.tcp": "localhost:514"
        "syslog.tenantID.tcp": "123:0"
        "syslog.compressMethod.tcp": "gzip"
        "syslog.tls": false
        "syslog.tlsKeyFile": ""
        "syslog.tlsCertFile": ""
      syslog-input-2:
        "syslog.listenAddr.tcp": ":6514"
        "syslog.tenantID.tcp": "567:0"
        "syslog.compressMethod.tcp": "none"
        "syslog.tls": true
        "syslog.tlsKeyFile": "/path/to/tls/key"
        "syslog.tlsCertFile": "/path/to/tls/cert"
```

### Forward logs to VictoriaLogs with vlagent

`victorialogs::vlagent` inherits `version`, `edition` and `install_method`
from the main `victorialogs` class when set, so in the simplest case you only
declare instances. At least one `remoteWrite.url` option is required per
instance.

```puppet
class { 'victorialogs::vlagent':
  version   => '1.52.0',
  instances => {
    single => {
      options => {
        'common' => {
          'remoteWrite.url' => 'http://localhost:9428/insert/native',
        },
      },
    },
  },
}
```

Same as above, but configured in Hiera:

```puppet
include victorialogs::vlagent
```

```yaml
victorialogs::vlagent::version: "1.52.0"
victorialogs::vlagent::instances:
  single:
    options:
      common:
        "remoteWrite.url": "http://localhost:9428/insert/native"
```

Install from a package or use an externally managed binary instead of the
default GitHub archive:

```puppet
class { 'victorialogs::vlagent':
  install_method => 'package',
  package_name   => 'vlagent',
  version        => '1.52.0',
  instances      => {
    single => {
      options => {
        'common' => {
          'remoteWrite.url' => 'http://localhost:9428/insert/native',
        },
      },
    },
  },
}

class { 'victorialogs::vlagent':
  install_method => 'none',
  binary_path    => '/usr/local/bin/vlagent-prod',
  instances      => {
    single => {
      options => {
        'common' => {
          'remoteWrite.url' => 'http://localhost:9428/insert/native',
        },
      },
    },
  },
}
```

### Install the vlogscli tool

`victorialogs::vlogscli` installs only the `vlogscli` binary from the
`vlutils` bundle. It also inherits `version`, `edition` and `install_method`
from the main `victorialogs` class when set.

```puppet
class { 'victorialogs::vlogscli':
  version => '1.52.0',
}
```

Same as above, but configured in Hiera:

```puppet
include victorialogs::vlogscli
```

```yaml
victorialogs::vlogscli::version: "1.52.0"
```

Install from a package or use an externally managed binary:

```puppet
class { 'victorialogs::vlogscli':
  install_method => 'package',
  package_name   => 'vlogscli',
  version        => '1.52.0',
}

class { 'victorialogs::vlogscli':
  install_method => 'none',
  binary_path    => '/usr/local/bin/vlogscli',
}
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
