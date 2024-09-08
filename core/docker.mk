# The docker layer.
#
# The docker layer is responsible for:
# - building the specified docker image.
# - running the resulting docker image.
# - mounting the required volumes.
# - binding the local user and group.
# - binding the local ssh configuration.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))/..)

# Include the common makefiles.
include ${OPENBAR_DIR}/includes/verify-environment.mk
include ${OPENBAR_DIR}/includes/common.mk

# Load the configuration variables.
ifeq ($(realpath ${CONFIG}),)
  $(error Configuration file not found)
else
  $(call config-load-variables)
endif

# Include the common container makefile.
include ${OPENBAR_DIR}/includes/container.mk

# The "docker build" command line.
DOCKER_BUILD := docker build
DOCKER_BUILD += ${CONTAINER_BUILD_ARGS}
DOCKER_BUILD += ${OB_DOCKER_BUILD_EXTRA_ARGS}
DOCKER_BUILD += ${OB_CONTAINER_CONTEXT}

# The "docker run" command line.
DOCKER_RUN := docker run
DOCKER_RUN += ${CONTAINER_RUN_ARGS}

# Bind the local user and group using the docker entrypoint.
DOCKER_RUN += -v ${OPENBAR_DIR}/scripts/docker-entrypoint.sh:/sbin/docker-entrypoint.sh:ro
DOCKER_RUN += --entrypoint docker-entrypoint.sh

DOCKER_RUN += -e OB_DOCKER_HOME=${OB_CONTAINER_HOME}
DOCKER_RUN += -e OB_DOCKER_UID=$$(id -u)
DOCKER_RUN += -e OB_DOCKER_GID=$$(id -g)

ifdef OB_DOCKER_GROUPS
  DOCKER_RUN += -e OB_DOCKER_GROUPS=$(call comma-list,${OB_DOCKER_GROUPS})
endif

# Add optional extra arguments.
DOCKER_RUN += ${OB_DOCKER_RUN_EXTRA_ARGS}

# Use the previously build image.
DOCKER_RUN += ${CONTAINER_TAG}

# All targets are forwarded to the next layer inside the docker.
${OB_ALL_TARGETS}: .forward

ifeq (${OB_TYPE}, yocto)
  NEXT_LAYER := ${OPENBAR_DIR}/core/bitbake-init-build-env.mk
else
  NEXT_LAYER := ${OPENBAR_DIR}/core/config.mk
endif

.PHONY: .forward
.forward: .docker-build | ${CONTAINER_VOLUME_HOSTDIRS}
	${DOCKER_RUN} \
		${MAKE} -f ${NEXT_LAYER} $(filter -j%,${MAKEFLAGS}) ${MAKECMDGOALS}

.PHONY: .docker-build
.docker-build:
	echo "Building docker image '${CONTAINER_TAG}'"
	${QUIET} ${DOCKER_BUILD}
