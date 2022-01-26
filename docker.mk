WIZARD_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

include ${WIZARD_DIR}/lib/config.mk
include ${WIZARD_DIR}/lib/submake.mk
include ${WIZARD_DIR}/lib/common.mk
include ${WIZARD_DIR}/lib/forward.mk

DOCKER_DIR ?= configs/docker

DOCKER ?= default
DOCKER_FILENAME ?= Dockerfile
DOCKER_CONTEXT ?= ${DOCKER_DIR}/${DOCKER}
DOCKER_FILE ?= ${DOCKER_CONTEXT}/${DOCKER_FILENAME}

DOCKER_IMAGE := ${PROJECT}/${DOCKER}
DOCKER_TAG := ${DOCKER_IMAGE}:$$(id -u)

DOCKER_BUILD := docker build
DOCKER_BUILD += -t ${DOCKER_TAG}
DOCKER_BUILD += -f ${DOCKER_FILE}
DOCKER_BUILD += ${DOCKER_CONTEXT}

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
DOCKER_RUN += -v ${WIZARD_DIR}/lib/docker-entrypoint.sh:/usr/local/bin/docker-entrypoint.sh:ro
DOCKER_RUN += --entrypoint docker-entrypoint.sh

DOCKER_RUN += -e DOCKER_UID=$$(id -u)
DOCKER_RUN += -e DOCKER_GID=$$(id -g)

ifdef DOCKER_GROUPS
 DOCKER_RUN += -e DOCKER_GROUPS=$(subst ${space},${comma},$(strip ${DOCKER_GROUPS}))
endif

# Bind local ssh configuration and authentication
DOCKER_RUN += -v ${HOME}/.ssh:/home/docker/.ssh

ifdef SSH_AUTH_SOCK
 DOCKER_RUN += -v ${SSH_AUTH_SOCK}:/home/docker/.ssh/socket
 DOCKER_RUN += -e SSH_AUTH_SOCK=/home/docker/.ssh/socket
 DOCKER_EXPORTED_VARIABLES += SSH_AUTH_SOCK
endif

# Mount the repo directory as working directory
DOCKER_RUN += -w ${REPO_DIR}
DOCKER_RUN += -v ${REPO_DIR}:${REPO_DIR}

# Export environment variables
override DOCKER_EXPORT_VARIABLES += ${DEFAULT_DOCKER_EXPORT_VARIABLES}

define export-variable
 ifdef ${1}
  ifeq ($(origin ${1}),$(filter $(origin ${1}),environment command line))
   DOCKER_RUN += -e ${1}=${${1}}
   DOCKER_EXPORTED_VARIABLES += ${1}
  endif
 endif
endef

$(foreach variable,$(sort ${DOCKER_EXPORT_VARIABLES}),\
	$(eval $(call export-variable,${variable})))

DOCKER_RUN += -e DOCKER_PRESERVE_ENV=$(subst ${space},${comma},$(strip ${DOCKER_EXPORTED_VARIABLES}))

# Mount other needed volumes
override DOCKER_VOLUMES += ${BUILD_DIR} ${DL_DIR} ${SSTATE_DIR}

define mount-volume
 ifeq ($(filter ${REPO_DIR}/%,$(abspath ${1})),)
  DOCKER_RUN += -v ${1}:${1}
 endif
endef

$(foreach volume,$(sort ${DOCKER_VOLUMES}),\
	$(eval $(call mount-volume,${volume})))

# Use the previously build image
DOCKER_RUN += ${DOCKER_TAG}

.PHONY: .docker-run
.docker-run: .docker-build | ${DOCKER_VOLUMES}
	${DOCKER_RUN} $(call trap,SIGINT,${MAKE_FORWARD} -f ${WIZARD_DIR}/oe-init-build-env.mk)

${DOCKER_VOLUMES}:
	mkdir -p $@

.forward: .docker-run
