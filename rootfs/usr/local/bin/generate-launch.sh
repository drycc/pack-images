#!/usr/bin/env bash
set -eo pipefail

echo "---> Generate Launcher"
layers_dir=$1

function procfile_to_launch() {
  procfile=$(< Procfile yj -yj)
  for key in $(echo "${procfile}" | jq -r "to_entries | .[] | .key"); do
    cat >> "${layers_dir}/launch.toml" <<EOL
[[processes]]
  type = "${key}"
  command = ["launcher"]
  args = ["$(echo "$procfile" | jq -r ".$key" | sed 's/ /", "/g')"]

EOL
  done
}


if [[ -f Procfile ]]; then
  rm -rf "${layers_dir}/launch.toml"
  procfile_to_launch
elif [[ -f launch.toml ]]; then
  cp launch.toml "${layers_dir}/launch.toml"
else
  echo "---> Error generating launcher, no Procfile and launch.toml found."
  exit 1
fi
