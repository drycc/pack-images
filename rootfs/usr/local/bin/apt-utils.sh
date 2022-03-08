#!/usr/bin/env bash

APT_DIR=/tmp/$(whoami)/apt
APT_CACHE_DIR="$APT_DIR/apt/cache"
APT_STATE_DIR="$APT_DIR/apt/state"
mkdir -p "$APT_CACHE_DIR/archives/partial"
mkdir -p "$APT_STATE_DIR/lists/partial"
APT_OPTIONS="-o debug::nolocking=true"
APT_OPTIONS="$APT_OPTIONS -o dir::cache=$APT_CACHE_DIR"
APT_OPTIONS="$APT_OPTIONS -o dir::state=$APT_STATE_DIR"
if [[ -f ".sources-list" ]]; then
    APT_OPTIONS="$APT_OPTIONS -o dir::etc::sourcelist=$(pwd)/.sources-list"
else
    APT_OPTIONS="$APT_OPTIONS -o dir::etc::sourcelist=/etc/apt/sources.list"
fi

apt-update() {
    # shellcheck disable=SC2086
    apt-get $APT_OPTIONS update
}

apt-clean() {
    # shellcheck disable=SC2086
    apt-get $APT_OPTIONS clean
}

apt-install() {
    APT_INSTALL_DIR="${APT_INSTALL_DIR:?APT_INSTALL_DIR is required}"
    # shellcheck disable=SC2086
    for DEB_URL in $(apt-get $APT_OPTIONS install --print-uris -qq "$@" | cut -d"'" -f2)
    do
        DEB_FILE="${APT_CACHE_DIR}"/$(echo "$DEB_URL" | awk -F "/" '{print $NF}')
        if [[ ! -f "${DEB_FILE}" ]] ; then
            curl -fsSL -o "${DEB_FILE}" "${DEB_URL}"
        fi
        dpkg -x "${DEB_FILE}" "$APT_INSTALL_DIR"
        pkgconfig_list=$(find "$APT_INSTALL_DIR"/usr/lib/*-linux-gnu/pkgconfig/*.pc 2>/dev/null || echo "")
        for pkgconfig in ${pkgconfig_list}
        do
            sed -i "s#/usr/lib/#$APT_INSTALL_DIR/usr/lib/#g" "${pkgconfig}"
            sed -i "s#/usr/include/#$APT_INSTALL_DIR/usr/include/#g" "${pkgconfig}"
        done
    done
}