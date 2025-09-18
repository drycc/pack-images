# If DRYCC_REGISTRY is not set, try to populate it from legacy DEV_REGISTRY
DEV_REGISTRY ?= registry.drycc.cc
DRYCC_REGISTRY ?= ${DEV_REGISTRY}
PLATFORM ?= $(shell python3 _scripts/utils.py platform)
ARCH ?= $(shell python3 _scripts/utils.py arch)
PLATFORM_API ?= 0.14
BUILDPACK_API ?= 0.11
LIFECYCLE_VERSION ?= v0.20.14
STACK_ID = drycc-${CODENAME}
STACK_RUN_IMAGE = ${DRYCC_REGISTRY}/drycc/pack:${CODENAME}-${PLATFORM}-${ARCH}
STACK_BUILD_IMAGE = ${DRYCC_REGISTRY}/drycc/pack:${CODENAME}-${PLATFORM}-${ARCH}-build
BUILDPACKS_IMAGE = ${DRYCC_REGISTRY}/drycc/buildpacks:${CODENAME}-${PLATFORM}-${ARCH}

SHELLCHECK_PREFIX := podman run --rm -v ${CURDIR}:/workdir -w /workdir ${DRYCC_REGISTRY}/drycc/go-dev shellcheck
SHELL_SCRIPTS = $(shell find "buildpacks" -name '*.sh') $(shell find "rootfs" -name '*.sh') $(wildcard buildpacks/*/bin/*)

SHELL=/bin/bash -o pipefail

pack:
	@podman build --pull -f Dockerfile.run \
	  --build-arg STACK_ID=${STACK_ID} \
	  --build-arg BASE_IMAGE=${DRYCC_REGISTRY}/drycc/base:${CODENAME} \
	  -t ${STACK_RUN_IMAGE} .
	@podman build -f Dockerfile.build \
	  --build-arg BASE_IMAGE=${STACK_RUN_IMAGE} \
	  --build-arg PLATFORM_API=${PLATFORM_API} \
	  -t ${STACK_BUILD_IMAGE} .

publish-pack: pack
	@podman push ${STACK_RUN_IMAGE}
	@podman push ${STACK_BUILD_IMAGE}

buildpack:
	BUILDPACK_API=${BUILDPACK_API} STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/go/buildpack.tmpl buildpacks/go/buildpack.toml
	BUILDPACK_API=${BUILDPACK_API} STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/java/buildpack.tmpl buildpacks/java/buildpack.toml
	BUILDPACK_API=${BUILDPACK_API} STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/node/buildpack.tmpl buildpacks/node/buildpack.toml
	BUILDPACK_API=${BUILDPACK_API} STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/php/buildpack.tmpl buildpacks/php/buildpack.toml
	BUILDPACK_API=${BUILDPACK_API} STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/python/buildpack.tmpl buildpacks/python/buildpack.toml
	BUILDPACK_API=${BUILDPACK_API} STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/ruby/buildpack.tmpl buildpacks/ruby/buildpack.toml
	BUILDPACK_API=${BUILDPACK_API} STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/rust/buildpack.tmpl buildpacks/rust/buildpack.toml
	STACK_ID=${STACK_ID} LIFECYCLE_VERSION=${LIFECYCLE_VERSION} STACK_RUN_IMAGE=${STACK_RUN_IMAGE} STACK_BUILD_IMAGE=${STACK_BUILD_IMAGE} \
	    python3 _scripts/utils.py toml builder.toml builder.toml.${PLATFORM}.${ARCH}
	DOCKER_HOST=unix://$(shell podman info -f "{{.Host.RemoteSocket.Path}}") \
		pack builder create ${BUILDPACKS_IMAGE} --config builder.toml.${PLATFORM}.${ARCH} --pull-policy if-not-present
	@rm -rf builder.toml.${PLATFORM}.${ARCH} buildpacks/*/buildpack.toml

publish-buildpack: buildpack
	@podman push ${BUILDPACKS_IMAGE}

publish: publish-pack publish-buildpack

test-style:
	${SHELLCHECK_PREFIX} $(SHELL_SCRIPTS)
