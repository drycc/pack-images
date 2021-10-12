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

## System

The basic image is based on Debian system, See the table below for system description：

STACK ID     | Buildpacks image                | Operating System
-------------|---------------------------------|---------------------------------
drycc-20     | docker.io/drycc/buildpacks:20   | Debian 11 Bullseye 

The basic layer of buildpack supports custom software sources and custom software.
For example, if we use alicloud to install libpq-dev, we can add `.deb-list` and `·source-list` files to the project.

```
cat > ".source-list" <<EOL
deb http://mirrors.cloud.aliyuncs.com/debian/ bullseye main non-free contrib
deb-src http://mirrors.cloud.aliyuncs.com/debian/ bullseye main non-free contrib
deb http://mirrors.cloud.aliyuncs.com/debian-security bullseye/updates main
deb-src http://mirrors.cloud.aliyuncs.com/debian-security bullseye/updates main
deb http://mirrors.cloud.aliyuncs.com/debian/ bullseye-updates main non-free contrib
deb-src http://mirrors.cloud.aliyuncs.com/debian/ bullseye-updates main non-free contrib
deb http://mirrors.cloud.aliyuncs.com/debian/ bullseye-backports main non-free contrib
deb-src http://mirrors.cloud.aliyuncs.com/debian/ bullseye-backports main non-free contrib
EOL

cat > ".deb-list" <<EOL
libpq-dev
EOL
```

## Reference

Pack Images bundles the following technologies together into a single cohesive distribution:

* [Stack Images](https://github.com/drycc/stack-images)
* [Pack Runtimes](https://github.com/drycc/pack-runtimes)
* [Pack CLI](https://github.com/buildpacks/pack)
* [Buildpacks lifecycle](https://github.com/buildpacks/lifecycle)