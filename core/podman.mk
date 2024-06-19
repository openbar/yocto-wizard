# The podman layer.
#
# The podman layer is responsible for:
# - building the specified podman image.
# - running the resulting podman image.
# - exporting the required environment variables.
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

# The "podman build" command line.
PODMAN_BUILD := podman build
PODMAN_BUILD += ${CONTAINER_BUILD_ARGS}
PODMAN_BUILD += ${OB_PODMAN_BUILD_EXTRA_ARGS}
PODMAN_BUILD += ${OB_CONTAINER_CONTEXT}

# The "podman run" command line.
PODMAN_RUN := podman run
PODMAN_RUN += ${CONTAINER_RUN_ARGS}

# Keep the current UID and GID inside the container.
PODMAN_RUN += --userns=keep-id

# Set the HOME, so ~ can be resolved.
PODMAN_RUN += -e HOME=${OB_CONTAINER_HOME}

# Add optional extra arguments.
PODMAN_RUN += ${OB_PODMAN_RUN_EXTRA_ARGS}

# Use the previously build image.
PODMAN_RUN += ${CONTAINER_TAG}

# All targets are forwarded to the next layer inside the podman.
${OB_ALL_TARGETS}: .forward

ifeq (${OB_TYPE}, yocto)
  NEXT_LAYER := ${OPENBAR_DIR}/core/bitbake-init-build-env.mk
else
  NEXT_LAYER := ${OPENBAR_DIR}/core/config.mk
endif

.PHONY: .forward
.forward: .podman-build | ${CONTAINER_VOLUME_HOSTDIRS}
	${PODMAN_RUN} \
		${MAKE} -f ${NEXT_LAYER} $(filter -j%,${MAKEFLAGS}) ${MAKECMDGOALS}

.PHONY: .podman-build
.podman-build:
	echo "Building podman image '${CONTAINER_TAG}'"
	${QUIET} ${PODMAN_BUILD}
