#!/usr/bin/env bash
set -eo pipefail

echo "---> Generate Project Metadata"

layers_dir=${1:?layer_dir is required}

cat >"${layers_dir}/project-metadata.toml" <<EOL
[source]
type = "s3"

[source.version]
uuid="$(cat /proc/sys/kernel/random/uuid)"

[source.metadata]
date="$(date --iso-8601=seconds -u)"
EOL