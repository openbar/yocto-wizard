WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))..)

include ${WZDIR}/core/lib/config.mk
include ${WZDIR}/core/lib/submake.mk
include ${WZDIR}/core/lib/common.mk
include ${WZDIR}/core/lib/forward.mk

DOCKERDIR := ${REPODIR}/configs/docker

DOCKER ?= default
DOCKERFILENAME ?= Dockerfile
DOCKERCONTEXT ?= ${DOCKERDIR}/${DOCKER}
DOCKERFILE ?= ${DOCKERCONTEXT}/${DOCKERFILENAME}

DOCKER_IMAGE := ${PROJECT}/${DOCKER}
DOCKER_TAG := ${DOCKER_IMAGE}:$$(id -u)

DOCKER_BUILD := docker build
DOCKER_BUILD += -t ${DOCKER_TAG}
DOCKER_BUILD += -f ${DOCKERFILE}
DOCKER_BUILD += ${DOCKERCONTEXT}

.PHONY: .docker-build
.docker-build:
	${QUIET} ${DOCKER_BUILD}

DOCKER_RUN := docker run
DOCKER_RUN += --rm			# Never save the running container
DOCKER_RUN += --log-driver=none		# Disables any logging for the container
DOCKER_RUN += --privileged		# Allow access to devices

# Allow to run interactive commands
ifeq ($(shell tty -s && echo interactive), interactive)
 DOCKER_RUN += --interactive --tty
endif

# Set the hostname to be identifiable
DOCKER_RUN += --hostname $(subst /,-,${DOCKER_IMAGE})

# Bind local user and group using the docker entrypoint
DOCKER_RUN += -v ${WZDIR}/core/lib/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh:ro
DOCKER_RUN += --entrypoint docker-entrypoint.sh

DOCKER_RUN += -e DOCKER_UID=$$(id -u)
DOCKER_RUN += -e DOCKER_GID=$$(id -g)

ifdef DOCKER_GROUPS
 DOCKER_RUN += -e DOCKER_GROUPS=$(subst ${space},${comma},$(strip ${DOCKER_GROUPS}))
endif

# Mount the repo directory as working directory
DOCKER_RUN += -w ${REPODIR}
DOCKER_RUN += -v ${REPODIR}:${REPODIR}

# Mount other needed volumes
DOCKER_VOLUMES := ${BUILDDIR} ${DL_DIR} ${SSTATE_DIR}

define mount-volume
 ifeq ($(filter ${REPODIR}/%,$(abspath ${1})),)
  DOCKER_RUN += -v ${1}:${1}
 endif
endef

$(foreach volume,${DOCKER_VOLUMES},$(eval $(call mount-volume,${volume})))

# Use the previously build image
DOCKER_RUN += ${DOCKER_TAG}

.PHONY: .docker-run
.docker-run: .docker-build | ${DOCKER_VOLUMES}
	${DOCKER_RUN} $(call trap,SIGINT,${MAKE_FORWARD} -f ${WZDIR}/core/oe-init-build-env.mk)

${DOCKER_VOLUMES}:
	mkdir -p $@

.forward: .docker-run
