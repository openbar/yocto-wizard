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
DOCKER_TAG := ${DOCKER_IMAGE}:${USER}

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
DOCKER_RUN += --interactive --tty	# Allow to run interactive commands
DOCKER_RUN += --privileged		# Allow access to devices

# Set the hostname to be identifiable
DOCKER_RUN += --hostname $(subst /,-,${DOCKER_IMAGE})

# Bind local user and group
DOCKER_RUN += -u $$(id -u):$$(id -g)
DOCKER_RUN += -v /etc/passwd:/etc/passwd:ro
DOCKER_RUN += -v /etc/group:/etc/group:ro
# The local shadow file is needed to make sudo happy (account validation)
DOCKER_RUN += -v /etc/shadow:/etc/shadow:ro

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
