# If DRYCC_REGISTRY is not set, try to populate it from legacy DEV_REGISTRY
CODENAME ?= bullseye
DEV_REGISTRY ?= docker.io
DRYCC_REGISTRY ?= ${DEV_REGISTRY}
PLATFORM ?= $(shell python3 _scripts/utils.py platform)
ARCH ?= $(shell python3 _scripts/utils.py arch)
LIFECYCLE_VERSION ?= v0.13.3
ifeq ($(ARCH),amd64)
LIFECYCLE_URL = https://github.com/buildpacks/lifecycle/releases/download/$(LIFECYCLE_VERSION)/lifecycle-${LIFECYCLE_VERSION}+linux.x86-64.tgz
else
LIFECYCLE_URL = https://github.com/buildpacks/lifecycle/releases/download/$(LIFECYCLE_VERSION)/lifecycle-${LIFECYCLE_VERSION}+linux.${ARCH}.tgz
endif
STACK_ID = drycc-${CODENAME}
STACK_RUN_IMAGE = ${DRYCC_REGISTRY}/drycc/pack:${CODENAME}-${PLATFORM}-${ARCH}
STACK_BUILD_IMAGE = ${DRYCC_REGISTRY}/drycc/pack:${CODENAME}-${PLATFORM}-${ARCH}-build
BUILDPACKS_IMAGE = ${DRYCC_REGISTRY}/drycc/buildpacks:${CODENAME}-${PLATFORM}-${ARCH}

SHELLCHECK_PREFIX := docker run --rm -v ${CURDIR}:/workdir -w /workdir ${DRYCC_REGISTRY}/drycc/go-dev shellcheck
SHELL_SCRIPTS = $(shell find "buildpacks" -name '*.sh') $(shell find "rootfs" -name '*.sh') $(wildcard buildpacks/*/bin/*)

SHELL=/bin/bash -o pipefail

pack:
	@docker build --pull -f Dockerfile.run \
	  --build-arg STACK_ID=${STACK_ID} \
	  --build-arg BASE_IMAGE=${DRYCC_REGISTRY}/drycc/base:${CODENAME} \
	  -t ${STACK_RUN_IMAGE} .
	@docker build -f Dockerfile.build \
	  --build-arg BASE_IMAGE=${STACK_RUN_IMAGE} \
	  -t ${STACK_BUILD_IMAGE} .

publish-pack: pack
	@docker push ${STACK_RUN_IMAGE}
	@docker push ${STACK_BUILD_IMAGE}

buildpack:
	STACK_ID=${STACK_ID} LIFECYCLE_URL=${LIFECYCLE_URL} STACK_RUN_IMAGE=${STACK_RUN_IMAGE} STACK_BUILD_IMAGE=${STACK_BUILD_IMAGE} python3 _scripts/utils.py toml builder.toml builder.toml.${PLATFORM}.${ARCH}
	@pack builder create ${BUILDPACKS_IMAGE} --config builder.toml.${PLATFORM}.${ARCH} --pull-policy if-not-present
	@rm -rf builder.toml.${PLATFORM}.${ARCH}

publish-buildpack: buildpack
	@docker push ${BUILDPACKS_IMAGE}

publish: publish-pack publish-buildpack

test-style:
	${SHELLCHECK_PREFIX} $(SHELL_SCRIPTS)
