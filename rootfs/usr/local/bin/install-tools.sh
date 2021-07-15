#!/bin/bash

architecture=$(dpkg --print-architecture)
if [[ "$architecture" == "amd64" ]]; then
  name="yj-linux"
else
  name="yj-linux-$architecture"
fi

curl -o /usr/local/bin/yj \
  -L https://kubernetes-release.uucin.com/drycc/$name
#  -L "https://github.com/sclevine/yj/releases/download/v5.0.0/$name"
chmod +x /usr/local/bin/yj
