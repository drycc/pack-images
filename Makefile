# If DRYCC_REGISTRY is not set, try to populate it from legacy DEV_REGISTRY
STACK ?= 20
VERSION ?= ${STACK}
DEV_REGISTRY ?= docker.io
DRYCC_REGISTRY ?= ${DEV_REGISTRY}

SHELLCHECK_PREFIX := docker run --rm -v ${CURDIR}:/workdir -w /workdir ${DRYCC_REGISTRY}/drycc/go-dev shellcheck
SHELL_SCRIPTS = $(shell find "buildpacks" -name '*.sh') $(shell find "rootfs" -name '*.sh') $(wildcard buildpacks/*/bin/*)

SHELL=/bin/bash -o pipefail

pack:
	@docker build --pull -f Dockerfile.build --build-arg STACK=drycc-${STACK} --build-arg BASE_IMAGE=registry.uucin.com/lijianguo/stack-images:${STACK}-build -t registry.uucin.com/lijianguo/pack:${VERSION}-build .
	@docker build --pull -f Dockerfile.run --build-arg STACK=drycc-${STACK} --build-arg BASE_IMAGE=registry.uucin.com/lijianguo/stack-images:${STACK} -t registry.uucin.com/lijianguo/pack:${VERSION} .

publish-pack: pack
	@docker push registry.uucin.com/lijianguo/stack-images:${VERSION}-build
	@docker push registry.uucin.com/lijianguo/stack-images:${VERSION}

buildpack:
	@pack builder create registry.uucin.com/lijianguo/buildpacks:${VERSION} --config builder.toml --pull-policy if-not-present

publish-buildpack: buildpack
	@docker push registry.uucin.com/lijianguo/buildpacks:${VERSION}

publish: publish-pack publish-buildpack

test-style:
	${SHELLCHECK_PREFIX} $(SHELL_SCRIPTS)
