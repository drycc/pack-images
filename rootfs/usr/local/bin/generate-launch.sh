#!/usr/bin/env bash
set -eo pipefail

echo "---> Generate Launcher"

layers_dir=$1
procfile=$(< Procfile yj -yj)
for key in $(echo "$procfile" | jq -r "to_entries | .[] | .key"); do
  cat >> "$layers_dir/launch.toml" <<EOL
[[processes]]
type = "$key"
command = "$(echo "$procfile" | jq -r ".$key")"
EOL
done
