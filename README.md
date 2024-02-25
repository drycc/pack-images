# Drycc Pack Base Images

[![Build Status](https://woodpecker.drycc.cc/api/badges/drycc/pack-images/status.svg)](https://woodpecker.drycc.cc/drycc/pack-images)

This repository is responsible for building and publishing images that builds
with [Cloud Native Buildpacks'](https://buildpacks.io)
[`pack`](https://github.com/buildpacks/pack) command.

* [drycc/pack:$codename](https://registry.drycc.cc) - A CNB
  compatible run image based on drycc/pack:$codename
* [drycc/pack:$codename-build](https://registry.drycc.cc) - A CNB
  compatible build image based on drycc/pack:$codename-build

## Usage

`pack build myapp --builder drycc/buildpacks:$codename`

## System

The basic image is based on Debian system, See the table below for system description：

STACK ID        | Buildpacks image                              | Operating System
----------------|-----------------------------------------------|---------------------------------
drycc-$codename  | registry.drycc.cc/drycc/buildpacks:$codename | Debian $version $codename 

The basic layer of buildpack supports custom software sources and custom software.
For example, we can add `.deb-list`, `·source-list` and `.build-env` files to the project.

```
cat > ".sources-list" <<EOL
deb http://mirrors.cloud.aliyuncs.com/debian/ bookworm main non-free contrib
deb-src http://mirrors.cloud.aliyuncs.com/debian/ bookworm main non-free contrib
deb http://mirrors.cloud.aliyuncs.com/debian-security bookworm/updates main
deb-src http://mirrors.cloud.aliyuncs.com/debian-security bookworm/updates main
deb http://mirrors.cloud.aliyuncs.com/debian/ bookworm-updates main non-free contrib
deb-src http://mirrors.cloud.aliyuncs.com/debian/ bookworm-updates main non-free contrib
deb http://mirrors.cloud.aliyuncs.com/debian/ bookworm-backports main non-free contrib
deb-src http://mirrors.cloud.aliyuncs.com/debian/ bookworm-backports main non-free contrib
EOL

cat > ".deb-list" <<EOL
libpq-dev
EOL

cat > ".build-env" <<EOL
PIP_INDEX_URL=https://mirrors.cloud.tencent.com/pypi/simple/
EOL
```

## Reference

Pack Images bundles the following technologies together into a single cohesive distribution:

* [Stack Images](https://github.com/drycc/stack-images)
* [Pack CLI](https://github.com/buildpacks/pack)
* [Buildpacks lifecycle](https://github.com/buildpacks/lifecycle)