#!/usr/bin/env bash

# shellcheck source=/dev/null
. apt-utils.sh
apt-update

layers_dir="$1"

_install_deps() {
    local deps_file="$1"
    local deps_layer_dir="$2"
    export APT_INSTALL_DIR="${deps_layer_dir}"
    # shellcheck disable=SC2046
    apt-install $(< "${deps_file}")
}

_create_deps_profile() {
    local deps_layer_dir="$1"
    mkdir -p "${deps_layer_dir}/profile.d"
    cat > "${deps_layer_dir}/profile.d/deps.sh" <<EOL
export PATH="${deps_layer_dir}/usr/bin:${deps_layer_dir}/bin:\${PATH}"
export C_INCLUDE_PATH="${deps_layer_dir}/usr/include:\${C_INCLUDE_PATH}"
export CPLUS_INCLUDE_PATH="${deps_layer_dir}/usr/include:\${CPLUS_INCLUDE_PATH}"
export LIBRARY_PATH="${deps_layer_dir}/lib/$(uname -m)-linux-gnu:${deps_layer_dir}/usr/lib/$(uname -m)-linux-gnu:\${LIBRARY_PATH}"
export LD_LIBRARY_PATH="${deps_layer_dir}/lib/$(uname -m)-linux-gnu:${deps_layer_dir}/usr/lib/$(uname -m)-linux-gnu:\${LD_LIBRARY_PATH}"
export PKG_CONFIG_PATH="${deps_layer_dir}/lib/$(uname -m)-linux-gnu/pkg-config:${deps_layer_dir}/usr/lib/$(uname -m)-linux-gnu/pkg-config:\${PKG_CONFIG_PATH}"
EOL
}

_create_deps_metadata() {
    local deps_type="$1"
    local deps_layer_dir="${layers_dir}"/"$deps_type"
    local launch=true
    if [[ "${deps_type}" == "build-deps" ]]; then
        launch=false
    fi
    cat > "${deps_layer_dir}.toml" <<EOL
[types]
cache = true
build = true
launch = ${launch}

[metadata]
version = "${local_checksum}"
EOL
}

generate_base_layer() {
    base_layer="${layers_dir}"/base
    mkdir -p "${base_layer}/profile.d" 
    cat > "${base_layer}/profile.d/base.sh" <<EOL
    rm -rf /opt/drycc
    ln -s "${layers_dir}" /opt/drycc
EOL
    cat > "${base_layer}.toml" <<EOL
[types]
cache = true
build = true
launch = true

[metadata]
version = "1.0.0"
EOL
}

generate_deps_layer() {
    local deps_type="$1"
    local deps_file=."$deps_type"
    local deps_layer_dir="${layers_dir}"/"$deps_type"
    if [[ -f "${deps_file}" &&  $(<"${deps_file}") != "" ]]; then
        echo "---> Generate ${deps_type} layer"
        sort "${deps_file}" -u -o "${deps_file}"
        local_checksum=$(sha256sum "${deps_file}" | cut -d ' ' -f 1 || echo 'not found')
        remote_checksum='not found'
        if [[ -f "${deps_layer_dir}.toml" ]]; then
            remote_checksum=$(< "${deps_layer_dir}.toml" yj -t | jq -r .metadata.version 2>/dev/null || echo 'not found')
        fi
        if [[ "${local_checksum}" == "${remote_checksum}" ]] ; then
            echo "---> Reusing deps layer"
        else
            rm -rf "${deps_layer_dir}"
            mkdir -p "${deps_layer_dir}"
            _install_deps "${deps_file}" "${deps_layer_dir}"
            _create_deps_profile "${deps_layer_dir}"
            _create_deps_metadata "${deps_type}"
        fi
        # shellcheck source=/dev/null
        . "${deps_layer_dir}/profile.d/deps.sh"
    else
        rm -rf "${deps_layer_dir}"
        echo "---> Skip generate ${deps_type} layer"
    fi
}

generate_stack_layer() {
    stack_name=${1:?stack_name is required}
    plan_path=${2:?plan_path is required}
    launch=${3:?launch is required}
    stack_layer_dir="${layers_dir}"/"${stack_name}"
    mkdir -p "${stack_layer_dir}"
    # determine stack version provided during detection
    stack_version=$(yj <"${plan_path}" -t | jq -r ".entries[] | select(.name == \"${stack_name}\") | .metadata.version")
    remote_stack_version='not found'
    if [[ -f "${stack_layer_dir}.toml" ]]; then
        remote_stack_version=$(yj <"${stack_layer_dir}.toml" -t | jq -r .metadata.version 2>/dev/null || echo 'not found')
    fi
    if [[ "${stack_version}" == "${remote_stack_version}" ]]; then
        echo "---> Reusing ${stack_name} ${stack_version}"
    else
        echo "---> Downloading and extracting ${stack_name} ${stack_version}"
        export LAYERS_DIR=${layers_dir}
        export STACK_NAME=${stack_name}
        install-stack "${stack_name}" "${stack_version}"
        cat >"${stack_layer_dir}.toml" <<EOL
[types]
cache = true
build = true
launch = ${launch}

[metadata]
version = "${stack_version}"
EOL
    fi
}

generate_base_layer