# The podman layer.
#
# The podman layer is responsible for:
# - building the specified podman image.
# - running the resulting podman image with the appropriate environment and volumes.
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

# The "podman build" command line.
CONTAINER_BUILD := podman build
CONTAINER_BUILD += ${CONTAINER_BUILD_ARGS}
CONTAINER_BUILD += ${OB_PODMAN_BUILD_EXTRA_ARGS}
CONTAINER_BUILD += ${OB_CONTAINER_CONTEXT}

# The "podman run" command line.
CONTAINER_RUN := podman run
CONTAINER_RUN += ${CONTAINER_RUN_ARGS}

# Keep the current UID and GID inside the container.
CONTAINER_RUN += --userns=keep-id

# Disable podman PIDs limit
CONTAINER_RUN += --pids-limit=-1

# Set the HOME, so ~ can be resolved.
CONTAINER_RUN += -e HOME=${OB_CONTAINER_HOME}

# Ensure HOME is writable.
LOCAL_HOME := $(shell mktemp -d)
CONTAINER_RUN := set -e; trap "rm -rf ${LOCAL_HOME}" EXIT; ${CONTAINER_RUN}
CONTAINER_RUN += -v ${LOCAL_HOME}:${OB_CONTAINER_HOME}

# Add optional extra arguments.
CONTAINER_RUN += ${OB_PODMAN_RUN_EXTRA_ARGS}

# Use the previously build image.
CONTAINER_RUN += ${CONTAINER_TAG}
