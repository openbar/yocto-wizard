# The docker layer.
#
# The docker layer is responsible for:
# - building the specified docker image.
# - running the resulting docker image.
# - exporting the required environment variables.
# - mounting the required volumes.
# - binding the local user and group.
# - binding the local ssh configuration.

# The wizard directory. This must be done before any includes.
WIZARD_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

# Include the common makefiles.
include ${WIZARD_DIR}/includes/verify-environment.mk
include ${WIZARD_DIR}/includes/common.mk

# Load the configuration variables.
ifeq ($(realpath ${CONFIG}),)
  $(error Configuration file not found)
else
  $(call config-load-variables)
endif

## docker-sanitize <string>
# Sanitize a string to be used as a docker name or tag.
docker-sanitize = $(shell echo ${1} | awk -f ${WIZARD_DIR}/scripts/docker-sanitize.awk)

## comma-list <list>
# Convert a space separated list to a comma separated list.
comma-list = $(subst ${SPACE},${COMMA},$(strip ${1}))

# The default docker configuration.
DOCKER          ?= default
DOCKER_FILENAME ?= Dockerfile
DOCKER_CONTEXT  ?= ${DOCKER_DIR}/${DOCKER}
DOCKER_FILE     ?= ${DOCKER_CONTEXT}/${DOCKER_FILENAME}

# The generated docker variables.
DOCKER_PROJECT := $(call docker-sanitize,$(notdir ${REPO_DIR}))
DOCKER_IMAGE   := ${DOCKER_PROJECT}/$(call docker-sanitize,${DOCKER})
DOCKER_TAG     := ${DOCKER_IMAGE}:$(call docker-sanitize,${USER})

# The "docker build" command line.
DOCKER_BUILD := docker build
DOCKER_BUILD += -t ${DOCKER_TAG}
DOCKER_BUILD += -f ${DOCKER_FILE}
DOCKER_BUILD += ${DOCKER_CONTEXT}

# The "docker run" command line.
DOCKER_RUN := docker run
DOCKER_RUN += --rm			# Never save the running container.
DOCKER_RUN += --log-driver=none		# Disables any logging for the container.
DOCKER_RUN += --privileged		# Allow access to devices.

# Allow to run interactive commands.
ifeq ($(shell tty -s && echo interactive), interactive)
  DOCKER_RUN += --interactive --tty
endif

# Set the hostname to be identifiable.
DOCKER_RUN += --hostname $(subst /,-,${DOCKER_IMAGE})

# Bind the local user and group using the docker entrypoint.
DOCKER_RUN += -v ${WIZARD_DIR}/scripts/docker-entrypoint.sh:/sbin/docker-entrypoint.sh:ro
DOCKER_RUN += --entrypoint docker-entrypoint.sh

DOCKER_RUN += -e DOCKER_UID=$$(id -u)
DOCKER_RUN += -e DOCKER_GID=$$(id -g)

ifdef DOCKER_GROUPS
  DOCKER_RUN += -e DOCKER_GROUPS=$(call comma-list,${DOCKER_GROUPS})
endif

# Bind the local ssh configuration and authentication.
DOCKER_RUN += -v ${HOME}/.ssh:/home/docker/.ssh

ifdef SSH_AUTH_SOCK
  DOCKER_RUN += -v ${SSH_AUTH_SOCK}:/tmp/ssh.socket
  DOCKER_RUN += -e SSH_AUTH_SOCK=/tmp/ssh.socket
  DOCKER_EXPORTED_VARIABLES += SSH_AUTH_SOCK
endif

# Mount the repo directory as working directory.
DOCKER_RUN += -w ${REPO_DIR}
DOCKER_RUN += -v ${REPO_DIR}:${REPO_DIR}

# Export the required environment variables.
override DOCKER_EXPORT_VARIABLES += REPO_DIR BUILD_DIR VERBOSE
override DOCKER_EXPORT_VARIABLES += DEFCONFIG_DIR DOCKER_DIR OE_INIT_BUILD_ENV
override DOCKER_EXPORT_VARIABLES += BB_EXPORT_VARIABLES ${BB_EXPORT_VARIABLES}
override DOCKER_EXPORT_VARIABLES += BB_LAYERS
override DOCKER_EXPORT_VARIABLES += DL_DIR SSTATE_DIR DISTRO MACHINE

define export-variable
  ifdef ${1}
    ifeq ($(origin ${1}),$(filter $(origin ${1}),environment command line))
      DOCKER_RUN += -e ${1}=${${1}}
      DOCKER_EXPORTED_VARIABLES += ${1}
    endif
  endif
endef

$(call foreach-eval,${DOCKER_EXPORT_VARIABLES},export-variable)

DOCKER_RUN += -e DOCKER_PRESERVE_ENV=$(call comma-list,${DOCKER_EXPORTED_VARIABLES})

# Mount the required volumes if not already done.
override DOCKER_VOLUMES += ${BUILD_DIR} ${DL_DIR} ${SSTATE_DIR}

define mount-volume
  ifeq ($(filter ${REPO_DIR}/%,$(abspath ${1})),)
    DOCKER_RUN += -v ${1}:${1}
  endif
endef

$(call foreach-eval,${DOCKER_VOLUMES},mount-volume)

# Use the previously build image.
DOCKER_RUN += ${DOCKER_TAG}

# All targets are forwarded to the oe-init-build-env layer inside the docker.
${ALL_TARGETS}: .forward

.PHONY: .forward
.forward: .docker-build | ${DOCKER_VOLUMES}
	${DOCKER_RUN} ${SHELL} -c " \
		trap - SIGINT; \
		${MAKE} -f ${WIZARD_DIR}/oe-init-build-env.mk ${MAKECMDGOALS}"

.PHONY: .docker-build
.docker-build:
	${QUIET} ${DOCKER_BUILD}

# The docker volumes directories are created manually so that
# the owner is not root.
${DOCKER_VOLUMES}:
	mkdir -p $@
