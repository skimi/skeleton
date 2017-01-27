# Onyx

## Overview

PHP application skeleton based on Silex 2. Promote framework agnostic conception.

## Getting started

### Requirements

* docker, executable by your user (see official documentation to set it up)
* php >= 5.5.9

### Installation

Download deps, configure, ...
```bash
 make install
 make wizard-set-namespace
```
**Note :** In *wizard-set-namespace*, use **::** as namespace delimiter (ex: *Onyx::Cool::App*)


Launching web server (choose your port with WEB_PORT parameter, 80 if omitted)
```bash
 cd docker
 make WEB_PORT=82 up
```

See home page at http://localhost:82

## Asset management

See [Asset management](assets/readme.md).

## Accessibility tests

You can run the following command to test a page:

```
make a11y -- <YOUR_URL>
```

The command will quickly test your page using HTMLCS rules but it also launch an instance of [asqatasun](http://asqatasun.org/) that you can access through its portal (the command will give you the url).
