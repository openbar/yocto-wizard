# The docker layer.
#
# The docker layer is responsible for:
# - building the specified docker image.
# - running the resulting docker image.
# - exporting the required environment variables.
# - mounting the required volumes.
# - binding the local user and group.
# - binding the local ssh configuration.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

# Include the common makefiles.
include ${OPENBAR_DIR}/includes/verify-environment.mk
include ${OPENBAR_DIR}/includes/common.mk

# Load the configuration variables.
ifeq ($(realpath ${CONFIG}),)
  $(error Configuration file not found)
else
  $(call config-load-variables)
endif

## docker-sanitize <string>
# Sanitize a string to be used as a docker name or tag.
docker-sanitize = $(shell echo ${1} | awk -f ${OPENBAR_DIR}/scripts/docker-sanitize.awk)

## comma-list <list>
# Convert a space separated list to a comma separated list.
comma-list = $(subst ${SPACE},${COMMA},$(strip ${1}))

# The default docker configuration.
OB_DOCKER          ?= default
OB_DOCKER_FILENAME ?= Dockerfile
OB_DOCKER_CONTEXT  ?= ${OB_DOCKER_DIR}/${OB_DOCKER}
OB_DOCKER_FILE     ?= ${OB_DOCKER_CONTEXT}/${OB_DOCKER_FILENAME}

# The generated docker variables.
DOCKER_PROJECT := $(call docker-sanitize,$(notdir ${OB_ROOT_DIR}))
DOCKER_IMAGE   := ${DOCKER_PROJECT}/$(call docker-sanitize,${OB_DOCKER})
DOCKER_TAG     := ${DOCKER_IMAGE}:$(call docker-sanitize,${USER})

# The "docker build" command line.
DOCKER_BUILD := docker build
DOCKER_BUILD += -t ${DOCKER_TAG}
DOCKER_BUILD += -f ${OB_DOCKER_FILE}
DOCKER_BUILD += ${OB_DOCKER_BUILD_EXTRA_ARGS}
DOCKER_BUILD += ${OB_DOCKER_CONTEXT}
ifeq (${OB_VERBOSE}, 0)
  DOCKER_BUILD += --quiet
endif

# The "docker run" command line.
DOCKER_RUN := docker run
DOCKER_RUN += --rm			# Never save the running container.
DOCKER_RUN += --log-driver=none		# Disables any logging for the container.
DOCKER_RUN += --privileged		# Allow access to devices.

# Allow to run interactive commands.
ifeq ($(shell tty >/dev/null && echo interactive), interactive)
  DOCKER_RUN += --interactive --tty
endif

# Set the hostname to be identifiable.
DOCKER_RUN += --hostname $(subst /,-,${DOCKER_IMAGE})
DOCKER_RUN += --add-host $(subst /,-,${DOCKER_IMAGE}):127.0.0.1

# Bind the local user and group using the docker entrypoint.
DOCKER_RUN += -v ${OPENBAR_DIR}/scripts/docker-entrypoint.sh:/sbin/docker-entrypoint.sh:ro
DOCKER_RUN += --entrypoint docker-entrypoint.sh

DOCKER_RUN += -e OB_DOCKER_HOME=${OB_DOCKER_HOME}
DOCKER_RUN += -e OB_DOCKER_UID=$$(id -u)
DOCKER_RUN += -e OB_DOCKER_GID=$$(id -g)

ifdef OB_DOCKER_GROUPS
  DOCKER_RUN += -e OB_DOCKER_GROUPS=$(call comma-list,${OB_DOCKER_GROUPS})
endif

# Bind the local ssh configuration and authentication.
DOCKER_RUN += -v ${HOME}/.ssh:/home/docker/.ssh

ifdef SSH_AUTH_SOCK
  DOCKER_RUN += -v ${SSH_AUTH_SOCK}:/tmp/ssh.socket
  DOCKER_RUN += -e SSH_AUTH_SOCK=/tmp/ssh.socket
  DOCKER_EXPORTED_VARIABLES += SSH_AUTH_SOCK
endif

# Mount the repo directory as working directory.
DOCKER_RUN += -w ${OB_ROOT_DIR}
DOCKER_RUN += -v ${OB_ROOT_DIR}:${OB_ROOT_DIR}

# Export the required environment variables.
override OB_DOCKER_EXPORT_VARIABLES += OB_TYPE OB_ROOT_DIR OB_BUILD_DIR OB_VERBOSE
override OB_DOCKER_EXPORT_VARIABLES += OB_DEFCONFIG_DIR OB_DOCKER_DIR

ifeq (${OB_TYPE},yocto)
  override OB_DOCKER_EXPORT_VARIABLES += OB_BB_INIT_BUILD_ENV OB_BB_EXPORT_LIST_VARIABLE
  override OB_DOCKER_EXPORT_VARIABLES += OB_BB_EXPORT_VARIABLES ${OB_BB_EXPORT_VARIABLES}
  override OB_DOCKER_EXPORT_VARIABLES += OB_BB_LAYERS
  override OB_DOCKER_EXPORT_VARIABLES += DL_DIR SSTATE_DIR DISTRO MACHINE
endif

define export-variable
  ifdef ${1}
    ifeq ($(origin ${1}),$(filter $(origin ${1}),environment command line))
      DOCKER_RUN += -e ${1}=${${1}}
      DOCKER_EXPORTED_VARIABLES += ${1}
    endif
  endif
endef

$(call foreach-eval,${OB_DOCKER_EXPORT_VARIABLES},export-variable)

# Mount the required volumes if not already done.
override OB_DOCKER_VOLUMES += ${OB_BUILD_DIR}

ifeq (${OB_TYPE},yocto)
  override OB_DOCKER_VOLUMES += ${DL_DIR} ${SSTATE_DIR}
endif

first-field = $(firstword $(subst ${COLON},${SPACE},${1}))
last-field = $(lastword $(subst ${COLON},${SPACE},${1}))

DOCKER_VOLUMES :=
define mount-volume
  ifeq ($(filter ${OB_ROOT_DIR}/%,$(abspath $(call first-field,${1}))),)
    DOCKER_RUN += -v $(call first-field,${1}):$(call last-field,${1})
    DOCKER_VOLUMES += $(call first-field,${1})
  endif
endef

$(call foreach-eval,${OB_DOCKER_VOLUMES},mount-volume)

# Add optional extra arguments.
DOCKER_RUN += ${OB_DOCKER_RUN_EXTRA_ARGS}

# Use the previously build image.
DOCKER_RUN += ${DOCKER_TAG}

# All targets are forwarded to the next layer inside the docker.
${OB_ALL_TARGETS}: .forward

ifeq (${OB_TYPE},yocto)
  NEXT_LAYER := ${OPENBAR_DIR}/bitbake-init-build-env.mk
else
  NEXT_LAYER := ${OPENBAR_DIR}/config.mk
endif

.PHONY: .forward
.forward: .docker-build | ${DOCKER_VOLUMES}
	${DOCKER_RUN} \
		${MAKE} -f ${NEXT_LAYER} $(filter -j%,${MAKEFLAGS}) ${MAKECMDGOALS}

.PHONY: .docker-build
.docker-build:
	${QUIET} ${DOCKER_BUILD}

# The docker volumes directories are created manually so that
# the owner is not root.
${DOCKER_VOLUMES}:
	mkdir -p $@
