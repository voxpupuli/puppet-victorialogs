# Puppet module to manage VictoriaLogs

## Table of Contents

1. [Description](#description)
1. [Usage](#usage)

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
  version => '1.49.0',
  instances => {
    single => {
      options => {
        'common' => {
          '-storageDataPath' => '/var/lib/victorialogs/data00',
        }
        'syslog-input-1' => {
          '-syslog.listenAddr.tcp' => 'localhost:514',
          '-syslog.tenantID.tcp' => '123:0',
          '-syslog.compressMethod.tcp' => 'gzip',
          '-syslog.tls' => false,
          '-syslog.tlsKeyFile' => '',
          '-syslog.tlsCertFile' => '',
        }
        'syslog-input-2' => {
          '-syslog.listenAddr.tcp' => ':6514',
          '-syslog.tenantID.tcp' => '567:0',
          '-syslog.compressMethod.tcp' => 'none',
          '-syslog.tls' => true,
          '-syslog.tlsKeyFile' => '/path/to/tls/key',
          '-syslog.tlsCertFile' => '/path/to/tls/cert',
        }
      }
    }
  }
}
```

### Run a single-node VictoriaLogs with 2 syslog inputs, configured in Hiera

```puppet
include victorialogs
```

```yaml
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

## Reference

See [REFERENCE.md](REFERENCE.md)

## Author

This module is maintained by [Vox Pupuli](https://voxpupuli.org). It was originally written and
maintained by [Yury Bushmelev](https://github.com/jay7x)
