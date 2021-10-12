# If DRYCC_REGISTRY is not set, try to populate it from legacy DEV_REGISTRY
STACK ?= 20
VERSION ?= ${STACK}
DEV_REGISTRY ?= docker.io
DRYCC_REGISTRY ?= ${DEV_REGISTRY}

ARCH ?= $(shell python3 _scripts/utils.py arch)
LIFECYCLE_VERSION ?= v0.12.0-rc.1
ifeq ($(ARCH),amd64)
LIFECYCLE_URL = https://github.com/buildpacks/lifecycle/releases/download/$(LIFECYCLE_VERSION)/lifecycle-${LIFECYCLE_VERSION}+linux.x86-64.tgz
else
LIFECYCLE_URL = https://github.com/buildpacks/lifecycle/releases/download/$(LIFECYCLE_VERSION)/lifecycle-${LIFECYCLE_VERSION}+linux.${ARCH}.tgz
endif
STACK_RUN_IMAGE = docker.io/drycc/pack:20-linux-${ARCH}
STACK_BUILD_IMAGE = docker.io/drycc/pack:20-linux-${ARCH}-build

SHELLCHECK_PREFIX := docker run --rm -v ${CURDIR}:/workdir -w /workdir ${DRYCC_REGISTRY}/drycc/go-dev shellcheck
SHELL_SCRIPTS = $(shell find "buildpacks" -name '*.sh') $(shell find "rootfs" -name '*.sh') $(wildcard buildpacks/*/bin/*)

SHELL=/bin/bash -o pipefail

pack:
	@docker build --pull -f Dockerfile.build \
	  --build-arg STACK=drycc-${STACK} \
	  --build-arg BASE_IMAGE=${DRYCC_REGISTRY}/drycc/stack-images:${STACK} \
	  -t ${DRYCC_REGISTRY}/drycc/pack:${VERSION}-build .
	@docker build --pull -f Dockerfile.run \
	  --build-arg STACK=drycc-${STACK} \
	  --build-arg BASE_IMAGE=${DRYCC_REGISTRY}/drycc/stack-images:${STACK} \
	  -t ${DRYCC_REGISTRY}/drycc/pack:${VERSION} .

publish-pack: pack
	@docker push ${DRYCC_REGISTRY}/drycc/pack:${VERSION}-build
	@docker push ${DRYCC_REGISTRY}/drycc/pack:${VERSION}

buildpack:
	LIFECYCLE_URL=${LIFECYCLE_URL} STACK_RUN_IMAGE=${STACK_RUN_IMAGE} STACK_BUILD_IMAGE=${STACK_BUILD_IMAGE} python3 _scripts/utils.py toml builder.toml builder.toml.${ARCH}
	@pack builder create ${DRYCC_REGISTRY}/drycc/buildpacks:${VERSION} --config builder.toml.${ARCH} --pull-policy if-not-present
	@rm -rf builder.toml.${ARCH}

publish-buildpack: buildpack
	@docker push ${DRYCC_REGISTRY}/drycc/buildpacks:${VERSION}

publish: publish-pack publish-buildpack

test-style:
	${SHELLCHECK_PREFIX} $(SHELL_SCRIPTS)
