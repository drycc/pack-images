# Drycc Pack Base Images

[![Build Status](https://drone.drycc.cc/api/badges/drycc/pack-images/status.svg)](https://drone.drycc.cc/drycc/pack-images)

This repository is responsible for building and publishing images that builds
with [Cloud Native Buildpacks'](https://buildpacks.io)
[`pack`](https://github.com/buildpacks/pack) command.

* [drycc/pack:20](https://hub.docker.com/r/drycc/pack/tags/) - A CNB
  compatible run image based on drycc/pack:20
* [drycc/pack:20-build](https://hub.docker.com/r/drycc/pack/tags/) - A CNB
  compatible build image based on drycc/pack:20-build

## Usage

`pack build myapp --builder drycc/buildpacks:20`
