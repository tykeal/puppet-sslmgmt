# sslmgmt

[![Build Status](https://travis-ci.org/tykeal/puppet-sslmgmt.png)](https://travis-ci.org/tykeal/puppet-sslmgmt)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with sslmgmt](#setup)
    * [What sslmgmt affects](#what-sslmgmt-affects)
    * [Beginning with sslmgmt](#beginning-with-sslmgmt)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

A simple way to manage certificates in your infrastructure without an
HSM.

Do you have to deal with certificates scattered around your
infrastructure and you don't have an HSM to use? Do you have systems
that need to share a certificate? Then this is module for you!

## Module Description

This module is designed to read certificate keys, public certs and the
CA chaining needed to properly deploy certificate around your
environment and get it right everytime.

All information is stored in what we refer to as key banks which are
hash sets stored in hiera. If you're leery of storing your private keys
in your hiera please look at using eyaml to resolve this issue.

## Setup

### What sslmgmt affects

sslmgmt is a single define used for deploying a standalone public
certificate, with or without chaining information and by default also
deploys the private key in the appropriate location with sane file
modes.

### Beginning with sslmgmt

Install the module from the forge and then call the define on a given
certificate.

```yaml
sslmgmt::certs:
  cert_base_file_title:
    cert: |
          Your certificate
          here
    key: |
         Your certificate
         key here
```

```puppet
sslmgmt::cert{ 'cert_base_file_title':
  pkistore => 'default',
}
```

This will install a non-chained public certificate at
`/etc/pki/tls/certs/cert_base_file_title.pem` and a private key at
`/etc/pki/tls/private/cert_base_file_title.pem`

## Usage

As in the beginning with sslmgmt section configurations are driven by
hiera (`sslmgmt::ca` and `sslmgmt::certs`). It's pretty easy to things
using an extra hiera hash and a `create_resources` call.

```yaml
certs_for_system:
  cert_base_file_title:
    pkistore: 'default'
    chain: 'somechain'
  cert_base_file_title2:
    pkistore: 'default'
    ensure: 'absent'

sslmgmt::certs:
  cert_base_file_title:
    cert: |
          Your certificate
          here
    key: |
         Your certificate
         key here
  cert_base_file_title2:
    cert: |
          Even when setting absent you must define
          cert and key
    key: |
         Even when setting absent you must define
         cert and key

sslmgmt::ca:
  somechain: |
             Intermediate chain
             through to
             base CA
```

```puppet
$sslcerts = hiera(certs_for_system)
create_resources(sslmgmt::cert, $sslcerts)
```

## Reference

* `sslmgmt::cert`: Installs public certs as well as private keys.
  Configurable via hiera. *Type*: define

  The following options are accepted by `sslmgmt::cert`:

  * **required** `pkistore`: The pkistore that should be used. Normally `default` is
    all that should be used. If this is set to `custom` than the
    `customstore` option needs to be set. *Type*: string

  * **optional** `ensure`: Should the certificate / key be avaialble
    or removed. *Default*: `present`. *Options*: `present`, `absent`
    *Type*: string

  * **optional** `chain`: Should the CA chain be appeneded to the public
    certificate. *Default*: `undef`. If set, this should be the name of the CA
    option from the `sslmgmt::ca` hash. *Type*: hash

    The hash is defined as follows:

    ```yaml
    sslmgmt::ca:
      somecachain: |
                   You're CA chain defined as sub-signators then anchor
    ```

  * **optional** `customstore`: A hash containing certificate store
    information. This is only useful if `pkistore` was set to `custom`.
    Information used in the passed hash will be merged with the defined
    default store (see params.pp) so only values that are specifically
    overridden will be sumarily used. *Type*: hash

    ```puppet
    {
      'certpath' => 'fully qualified storage path for the cert',
      'keypath'  => 'fully qualified storage path for the key',
      'certmode' => 'the file mode to apply to the public cert',
      'owner'    => 'certificate / key owner'
      'group'    => 'certificate / key group'
    }
    ```

    In addition to the above parameters the following parameters can
    only be used when passing a `customstore`

    ```puppet
    'certfilename' => 'fully qualified filename to use for the public
                      certificate'
    'keyfilenmae'  => 'fully qualified filename to use for the private
                      key'
    ```

  * **optional** `installkey`: Should the private key be installed on
    the system as well? *Type*: boolean *Default*: true

  * **optional** `onefile`: Should the private key have the public cert
    (and potentially chain CA) appended to the file? *Type*: boolean
    *Default*: false

* `sslmgmt::ca_dh`: Installs CA certs (or DH agreements) into the cert
  store. This is useful for putting down chained CAs for use in CA
  validation / trust store. *Type*: define

  * **required** `pkistore`: The pkistore that should be used. Normally
    `default` is all that should be used. If this is set to `custom`
    than the `customstore` option needs to be set. *Type*: string

  * **optional** `ensure`: Should the certificate / key be avaialble
    or removed. *Default*: `present`. *Options*: `present`, `absent`
    *Type*: string

  * **optional** `customstore`: A hash containing certificate store
    information. This is only useful if `pkistore` was set to `custom`.
    Information used in the passed hash will be merged with the defined
    default store (see params.pp) so only values that are specifically
    overridden will be sumarily used. *Type*: hash

    ```puppet
    {
      'certpath' => 'fully qualified storage path for the cert',
      'certmode' => 'the file mode to apply to the public cert',
      'owner'    => 'certificate / key owner'
      'group'    => 'certificate / key group'
    }
    ```

    In addition to the above parameters the following parameters can
    only be used when passing a `customstore`

    ```puppet
    'certfilename' => 'fully qualified filename to use for the CA
                      certificate or DH agreement'
    ```

## Limitations

Only tested on EL7 at present

## Development

Please raise issues on GitHub or submit a pull request.
