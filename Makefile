# If DRYCC_REGISTRY is not set, try to populate it from legacy DEV_REGISTRY
DEV_REGISTRY ?= registry.drycc.cc
DRYCC_REGISTRY ?= ${DEV_REGISTRY}
PLATFORM ?= $(shell python3 _scripts/utils.py platform)
ARCH ?= $(shell python3 _scripts/utils.py arch)
PLATFORM_API ?= 0.11
LIFECYCLE_VERSION ?= v0.16.5
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
	  --build-arg PLATFORM_API=${PLATFORM_API} \
	  -t ${STACK_BUILD_IMAGE} .

publish-pack: pack
	@docker push ${STACK_RUN_IMAGE}
	@docker push ${STACK_BUILD_IMAGE}

buildpack:
	STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/go/buildpack.tmpl buildpacks/go/buildpack.toml
	STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/java/buildpack.tmpl buildpacks/java/buildpack.toml
	STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/node/buildpack.tmpl buildpacks/node/buildpack.toml
	STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/php/buildpack.tmpl buildpacks/php/buildpack.toml
	STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/python/buildpack.tmpl buildpacks/python/buildpack.toml
	STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/ruby/buildpack.tmpl buildpacks/ruby/buildpack.toml
	STACK_ID=${STACK_ID} python3 _scripts/utils.py toml buildpacks/rust/buildpack.tmpl buildpacks/rust/buildpack.toml
	STACK_ID=${STACK_ID} LIFECYCLE_URL=${LIFECYCLE_URL} STACK_RUN_IMAGE=${STACK_RUN_IMAGE} STACK_BUILD_IMAGE=${STACK_BUILD_IMAGE} python3 _scripts/utils.py toml builder.toml builder.toml.${PLATFORM}.${ARCH}
	@pack builder create ${BUILDPACKS_IMAGE} --config builder.toml.${PLATFORM}.${ARCH} --pull-policy if-not-present
	@rm -rf builder.toml.${PLATFORM}.${ARCH} buildpacks/*/buildpack.toml

publish-buildpack: buildpack
	@docker push ${BUILDPACKS_IMAGE}

publish: publish-pack publish-buildpack

test-style:
	${SHELLCHECK_PREFIX} $(SHELL_SCRIPTS)
