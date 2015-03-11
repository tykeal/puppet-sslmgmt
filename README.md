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
hash sets stored in hiera. If you're leary of storing your private keys
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

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

Here, list the classes, types, providers, facts, etc contained in your module.
This section should include all of the under-the-hood workings of your module so
people know what the module is touching on their system but don't need to mess
with things. (We are working on automating this section!)

## Limitations

Only tested on EL7 at present

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.
