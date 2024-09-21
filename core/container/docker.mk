# The docker layer.
#
# The docker layer is responsible for:
# - building the specified docker image.
# - running the resulting docker image with the appropriate environment and volumes.
# - forwarding the other targets to the type layer.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))/../..)

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
CONTAINER_BUILD := docker build
CONTAINER_BUILD += ${CONTAINER_BUILD_ARGS}
CONTAINER_BUILD += ${OB_DOCKER_BUILD_EXTRA_ARGS}
CONTAINER_BUILD += ${OB_CONTAINER_CONTEXT}

# The "docker run" command line.
CONTAINER_RUN := docker run
CONTAINER_RUN += ${CONTAINER_RUN_ARGS}

# Bind the local user and group using the docker entrypoint.
CONTAINER_RUN += -v ${OPENBAR_DIR}/scripts/docker-entrypoint.sh:/sbin/docker-entrypoint.sh:ro
CONTAINER_RUN += --entrypoint docker-entrypoint.sh

CONTAINER_RUN += -e OB_DOCKER_HOME=${OB_CONTAINER_HOME}
CONTAINER_RUN += -e OB_DOCKER_UID=$$(id -u)
CONTAINER_RUN += -e OB_DOCKER_GID=$$(id -g)

ifdef OB_DOCKER_GROUPS
  CONTAINER_RUN += -e OB_DOCKER_GROUPS="${OB_DOCKER_GROUPS}"
endif

# Add optional extra arguments.
CONTAINER_RUN += ${OB_DOCKER_RUN_EXTRA_ARGS}

# Use the previously build image.
CONTAINER_RUN += ${CONTAINER_TAG}
