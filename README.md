# nar [![Build Status](https://secure.travis-ci.org/h2non/nar.png?branch=master)][travis] [![Dependency Status](https://gemnasium.com/h2non/nar.png)][gemnasium] [![NPM version](https://badge.fury.io/js/nar.png)][npm]

> Bundle and package self-contained node.js applications that are ready-to-ship-and-run

<table>
<tr>
<td><b>Version</b></td><td>beta</td>
</tr>
</table>

## About

**nar** is a simple application packager utility for [node.js](http://nodejs.org)

It provides built-in support for creating, extracting and running applications
easily through a featured [command-line interface](#command-line-interface)
and asynchronous event-based [programmatic API](#programmatic-api)

## Features

- Simple command-line interface
- Easy-to-use asynchronous programmatic API
- Fully configurable from package.json
- Tarball with gzip compression/decompression
- Built-in support for archive extraction
- Built-in support for archive execution
- Supports application pre/post run hooks (as [npm scripts][npm-scripts])
- Allow to bundle dependencies by type
- Allow to bundle node binary for platform-specific runtime environments
- Transparent checksum file integrity verification

## Installation

It's recommended you install it as global package
```bash
$ npm install -g nar
```

If you need to use the API, you should install it as package dependency
```bash
$ npm install nar --save
```

## Configuration

It supports specific archive build configuration that can be defined as meta-data
in the `package.json` of your application

```json
{
  "name": "my-package",
  "version": "1.0.0",
  "archive": {
    "binary": true,
    "dependencies": true,
    "devDependencies": false,
    "peerDependencies": true
  }
}
```

### Config options

The following options can be declared in your application `package.json` as
properties members in the `archive` object

#### dependencies
Type: `boolean`
Default: `true`

#### devDependencies
Type: `boolean`
Default: `false`

#### peerDependencies
Type: `boolean`
Default: `true`

#### binary
Type: `boolean`
Default: `false`

Include the node.js binary in the generated archive.
This is usually useful when you want to deploy a obsessively fully self-contained application
in a sandboxed deployment or runtime environment

**Note**: node binary is OS and platform specific.
Take that into account if you are going to deploy the archive in multiple platforms

#### patterns
Type: `array`
Default: `['**']`

[Glob][glob] patterns for matching files to include or exclude.

nar will ignore matched patterns defined in [ignore-like files](#ignoring-files)

### Stage hooks

`nar` supports application pre/post execution hooks, that are also supported by `npm`

You should define it the `package.json` in the `scripts` properties

Supported hooks:
- `prestart`
- `start`
- `stop`
- `poststop`

Configuration example:
```json
{
  "name": "app",
  "version": "1.0.0",
  "scripts": {
    "prestart": "mkdir -p temp/logs",
    "start": "node app --env ${ENV}",
    "stop" "rm -rf cache"
  }
}
```

#### Useful features

##### Environment variables in hook commands

You can consum environment variables from hook comands using the `${VARNAME}` notation

##### Check nar execution environment

nar will expose the `NODE_NAR` environment variable in the hooks execution contexts and node application

You can make any environment runtime checks if your application needs a different behavior
dependending of the runtime environment

##### Ignoring files

nar will find ignore-like files in order to load
and match patterns of files to discard

Supported files by priority are:

- `.narignore`
- `.buildignore`
- `.npmignore`
- `.gitignore`

## Command-line interface

```
Usage: nar [options] [command]

Commands:

  create [options] [path]
    Create new aplication archive
  extract [options] [archive]
    Extract archive files
  run [options] [archive]
    Run archive files
  list [options] [archive]
    List archive files

Options:

  -h, --help     output usage information
  -V, --version  output the version number

Usage examples:

  $ nar create [path]
  $ nar run [archive]
  $ nar extract [archive] -o [directory]
  $ nar list [archive]

Command specific help:

  $ nar <command> --help
```

### create

Create a new archive from an existent application

```bash
$ nar create
$ nar create some/path
$ nar create path/to/package.json -o some-dir
$ nar create --debug --verbose --no-color
```

### extract

Extract archive files into directory

```bash
$ nar extract
$ nar extract app.nar
$ nar extract app.nar -o some-dir
$ nar extract app.nar --debug --verbose --no-color
```

### run
```bash
$ nar run app.nar
$ nar run app.nar --no-hooks
$ nar run app.nar --args-start '--env ${ENV}'
$ nar run app.nar --args-stop '--path ${PATH}'
```

##### Passing arguments to hook commands

```
$ nar run app.nar --args-start "--env ${ENV} --debug"
```

### list
```bash
$ nar list app.nar
$ nar list app.nar --no-table
```

## Programmatic API

`nar` provides a ful featured programmatic API that can be consumed easily from other
node.js applications

For better approach, it's a fully event-based asynchronous API,

Basic example:
```js
var nar = require('nar')

var options = {
  dest: 'path/to/pkg'
  binary: true,
  dependencies: true,
  devDependencies: true
}

try {
  nar.create(options)
    .on('error', function (err) {
      throw err
    })
    .on('message', function (msg) {
      console.log(msg)
    })
    .on('end', function (path) {
      console.log('Archive created in: ' + path)
    })
} catch (e) {
  console.error('Cannot create the archive:', e.message)
}
```

### nar.create(options)
Fired events: `end, error, entry, message`

### nar.extract(options)
Fired events: `end, error, entry, message`

##### Options

- **path** `string` Path to nar archive. Required
- **dest** `string` Extract destination path. Default to random temporal directory
- **tmpdir** `string` Temporal directory to use. Default to random temporal directory

### nar.run(options)
Fired events: `end, error, entry, command, info, start, stdout, stderr, exit`

Read, extract and run an application. It will read [command scripts][npm-scripts] hooks in `package.json`

##### Options

- **path** `string` Path to nar archive. Required
- **dest** `string` Extract destination path. Defaults to random temporal directory
- **args** `object` Aditional argument to pass to hooks. Keys must have the same hook name
- **hooks** `boolean` Enable/disable run command hooks. Defaults to `true`
- **clean** `boolean` Clean app directory on exit. Defaults to `true`

### nar.list(options)
Options: `path`

Fired events: `end, error, entry`

Read and parse a given .nar archive, emitting the `entry` event for each existent file

##### Options

- **path** `string` Path to nar archive. Required

### nar.VERSION
Type: `string`

### Events

List of available events for subscription

- **end** ([result]) Task was completed successfully
- **error** `(error)` Some error happens and task cannot be completed
- **entry** `(entry)` On read/write file, usually fired from file streams
- **message** `(message)` General information status message, useful for debugging purposes
- **command** `(command)` Hook command to execute when run an application
- **info** `(config)` Expose the nar archive config
- **start** `(command)` On application start hook command
- **stdout** `(string)` Command execution stdout entry. Emits on every chunk of data
- **stderr** `(string)` Command execution stderr entry. Emits on every chunk of data
- **exit** `(code, hook)` When a hook command process ends

## Contributing

Wanna help? Cool! It will be really apreciated :)

`nar` is completely written in LiveScript language.
Take a look to the language [documentation][livescript] if you are new with it.
and follow the LiveScript language conventions defined in the [coding style guide][coding-style]

You must add new test cases for any new feature or refactor you do,
always following the same design/code patterns that already exist

### Development

Only [node.js](http://nodejs.org) is required for development

Clone/fork this repository
```
$ git clone https://github.com/h2non/nar.git && cd nar
```

Install dependencies
```
$ npm install
```

Compile code
```
$ make compile
```

Run tests
```
$ make test
```

Publish a new version
```
$ make publish
```

## License

Copyright (c) 2014 Tomas Aparicio

Released under the MIT license

[livescript]: http://livescript.net
[coding-style]: https://github.com/gkz/LiveScript-style-guide
[travis]: http://travis-ci.org/h2non/nar
[gemnasium]: https://gemnasium.com/h2non/nar
[npm]: http://npmjs.org/package/nar
[npm-scripts]: https://www.npmjs.org/doc/misc/npm-scripts.html
[glob]: https://github.com/isaacs/node-glob
