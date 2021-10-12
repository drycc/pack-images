#!/usr/bin/env bash

base_layer_dir="$1/base"

generate_layer() {
    APT_DIR=$(mktemp -d)
    APT_CACHE_DIR="$APT_DIR/apt/cache"
    APT_STATE_DIR="$APT_DIR/apt/state"
    mkdir -p "$APT_CACHE_DIR/archives/partial"
    mkdir -p "$APT_STATE_DIR/lists/partial"
    APT_OPTIONS="-o debug::nolocking=true"
    APT_OPTIONS="$APT_OPTIONS -o dir::cache=$APT_CACHE_DIR"
    APT_OPTIONS="$APT_OPTIONS -o dir::state=$APT_STATE_DIR"
    if [[ -f ".source-list" ]]; then
        APT_OPTIONS="$APT_OPTIONS -o dir::etc::sourcelist=$(pwd)/.source-list"
    else
        APT_OPTIONS="$APT_OPTIONS -o dir::etc::sourcelist=/etc/apt/sources.list"
    fi
    # shellcheck disable=SC2086
    apt-get $APT_OPTIONS update > /dev/null 2>&1
    # shellcheck disable=SC2086
    apt-get $APT_OPTIONS -y -d --reinstall install "$(< .deb-list)" > /dev/null 2>&1
    find "$APT_CACHE_DIR/archives/" -name "*.deb" -exec dpkg -x {} "$base_layer_dir/" \;
    
    mkdir -p "${base_layer_dir}/profile.d"
    cat > "${base_layer_dir}/profile.d/base.sh" <<EOL
export PATH="${base_layer_dir}/usr/bin:${base_layer_dir}/bin:${PATH}"
export C_INCLUDE_PATH="${base_layer_dir}/usr/include:${C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="${base_layer_dir}/usr/include:${CPLUS_INCLUDE_PATH}"
export LIBRARY_PATH="${base_layer_dir}/lib/$(uname -m)-linux-gnu:${base_layer_dir}/usr/lib/$(uname -m)-linux-gnu:${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${base_layer_dir}/lib/$(uname -m)-linux-gnu:${base_layer_dir}/usr/lib/$(uname -m)-linux-gnu:${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${base_layer_dir}/lib/$(uname -m)-linux-gnu/pkg-config:${base_layer_dir}/usr/lib/$(uname -m)-linux-gnu/pkg-config:${PKG_CONFIG_PATH}"
EOL
    cat > "${base_layer_dir}.toml" <<EOL
cache = true
build = true
launch = true
metadata = "${local_checksum}"
EOL
    rm -rf "$APT_DIR"
}

if [[ -f ".deb-list" ]]; then
    echo "---> Generate base layer"
    local_checksum=$(sha256sum .deb-list | cut -d ' ' -f 1 || echo 'not found')
    remote_checksum='not found'
    if [[ -f "${base_layer_dir}.toml" ]]; then
        remote_checksum=$(< "${base_layer_dir}.toml" yj -t | jq -r .metadata 2>/dev/null || echo 'not found')
    fi
    if [[ "${local_checksum}" == "${remote_checksum}" ]] ; then
        echo "---> Reusing base layer"
    else
        rm -rf "${base_layer_dir}"
        mkdir -p "${base_layer_dir}"
        generate_layer
    fi
    # shellcheck source=/dev/null
    . "${base_layer_dir}/profile.d/base.sh"
else
    rm -rf "${base_layer_dir}"
    echo "---> Skip generate base layer"
fi