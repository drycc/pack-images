# If DRYCC_REGISTRY is not set, try to populate it from legacy DEV_REGISTRY
STACK ?= 20
VERSION ?= ${STACK}
DEV_REGISTRY ?= docker.io
DRYCC_REGISTRY ?= ${DEV_REGISTRY}

SHELLCHECK_PREFIX := docker run --rm -v ${CURDIR}:/workdir -w /workdir ${DRYCC_REGISTRY}/drycc/go-dev shellcheck
SHELL_SCRIPTS = $(shell find "buildpacks" -name '*.sh') $(shell find "rootfs" -name '*.sh') $(wildcard buildpacks/*/bin/*)

SHELL=/bin/bash -o pipefail

pack:
	@docker build --pull -f Dockerfile.build --build-arg STACK=drycc-${STACK} --build-arg BASE_IMAGE=${DRYCC_REGISTRY}/drycc/stack-images:${STACK}-build -t ${DRYCC_REGISTRY}/drycc/pack:${VERSION}-build .
	@docker build --pull -f Dockerfile.run --build-arg STACK=drycc-${STACK} --build-arg BASE_IMAGE=${DRYCC_REGISTRY}/drycc/stack-images:${STACK} -t ${DRYCC_REGISTRY}/drycc/pack:${VERSION} .

publish-pack: pack
	@docker push ${DRYCC_REGISTRY}/drycc/pack:${VERSION}-build
	@docker push ${DRYCC_REGISTRY}/drycc/pack:${VERSION}

buildpack:
	@pack builder create ${DRYCC_REGISTRY}/drycc/buildpacks:${VERSION} --config builder.toml --pull-policy if-not-present

publish-buildpack: buildpack
	@docker push ${DRYCC_REGISTRY}/drycc/buildpacks:${VERSION}

publish: publish-pack publish-buildpack

test-style:
	${SHELLCHECK_PREFIX} $(SHELL_SCRIPTS)
