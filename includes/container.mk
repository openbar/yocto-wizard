## comma-list <list>
# Convert a space separated list to a comma separated list.
comma-list = $(subst ${SPACE},${COMMA},$(strip ${1}))

## container-sanitize <string>
# Sanitize a string to be used as a container name or tag.
container-sanitize = $(shell echo ${1} | awk -f ${OPENBAR_DIR}/scripts/container-sanitize.awk)

## container-volume <string>
# Format the volume string to be container compliant.
container-volume = $(shell echo ${1} | awk -f ${OPENBAR_DIR}/scripts/container-volume.awk)

## container-volume-hostdir <string>
# Get the host directory from a container volume string.
container-volume-hostdir = $(firstword $(subst ${COLON},${SPACE},${1}))

# The default container configuration.
OB_CONTAINER          ?= default
OB_CONTAINER_FILENAME ?= Dockerfile
OB_CONTAINER_CONTEXT  ?= ${OB_CONTAINER_DIR}/${OB_CONTAINER}
OB_CONTAINER_FILE     ?= ${OB_CONTAINER_CONTEXT}/${OB_CONTAINER_FILENAME}

# The generated container variables.
CONTAINER_PROJECT     := $(call container-sanitize,$(notdir ${OB_ROOT_DIR}))
CONTAINER_IMAGE       := ${CONTAINER_PROJECT}/$(call container-sanitize,${OB_CONTAINER})
CONTAINER_TAG         := ${CONTAINER_IMAGE}:$(call container-sanitize,${USER})
CONTAINER_HOSTNAME    := $(subst /,-,${CONTAINER_IMAGE})

# Export the required environment variables.
override OB_CONTAINER_EXPORT_VARIABLES += OB_TYPE OB_ROOT_DIR OB_BUILD_DIR OB_VERBOSE
override OB_CONTAINER_EXPORT_VARIABLES += OB_DEFCONFIG_DIR OB_CONTAINER_DIR

ifeq (${OB_TYPE},yocto)
  override OB_CONTAINER_EXPORT_VARIABLES += OB_BB_INIT_BUILD_ENV OB_BB_EXPORT_LIST_VARIABLE
  override OB_CONTAINER_EXPORT_VARIABLES += OB_BB_EXPORT_VARIABLES ${OB_BB_EXPORT_VARIABLES}
  override OB_CONTAINER_EXPORT_VARIABLES += OB_BB_LAYERS
  override OB_CONTAINER_EXPORT_VARIABLES += DEPLOY_DIR DL_DIR SSTATE_DIR DISTRO MACHINE
endif

CONTAINER_ENV_VARIABLES :=
define export-variable
  ifdef ${1}
    ifeq ($(origin ${1}),$(filter $(origin ${1}),environment command line))
      CONTAINER_ENV_VARIABLES += -e ${1}=${${1}}
    endif
  endif
endef

$(call foreach-eval,${OB_CONTAINER_EXPORT_VARIABLES},export-variable)

# Mount the required volumes if not already done.
override OB_CONTAINER_VOLUMES += ${OB_BUILD_DIR}

ifeq (${OB_TYPE},yocto)
  override OB_CONTAINER_VOLUMES += ${DEPLOY_DIR} ${DL_DIR} ${SSTATE_DIR}
endif

CONTAINER_VOLUMES :=
CONTAINER_VOLUME_HOSTDIRS :=
define mount-volume
  ifeq ($(filter ${OB_ROOT_DIR}/%,$(abspath $(call container-volume-hostdir,${1}))),)
    CONTAINER_VOLUMES += -v $(call container-volume,${1})
    CONTAINER_VOLUME_HOSTDIRS += $(call container-volume-hostdir,${1})
  endif
endef

$(call foreach-eval,${OB_CONTAINER_VOLUMES},mount-volume)

# The container volumes directories are created manually so that
# the owner is not root.
${CONTAINER_VOLUME_HOSTDIRS}:
	mkdir -p $@

# Container build default arguments.
CONTAINER_BUILD_ARGS := -t ${CONTAINER_TAG}
CONTAINER_BUILD_ARGS += -f ${OB_CONTAINER_FILE}

ifeq (${OB_VERBOSE}, 0)
  CONTAINER_BUILD_ARGS += --quiet
endif

CONTAINER_BUILD_ARGS += ${OB_CONTAINER_BUILD_EXTRA_ARGS}

# Container run default arguments.
CONTAINER_RUN_ARGS := --rm			# Never save the running container.
CONTAINER_RUN_ARGS += --log-driver=none		# Disables any logging for the container.
CONTAINER_RUN_ARGS += --privileged		# Allow access to devices.

# Allow to run interactive commands.
ifeq ($(shell tty >/dev/null && echo interactive), interactive)
  CONTAINER_RUN_ARGS += --interactive --tty -e TERM=${TERM}
endif

# Set the hostname to be identifiable.
CONTAINER_RUN_ARGS += --hostname ${CONTAINER_HOSTNAME}
CONTAINER_RUN_ARGS += --add-host ${CONTAINER_HOSTNAME}:127.0.0.1

# Bind the local ssh configuration and authentication.
CONTAINER_RUN_ARGS += -v ${HOME}/.ssh:${OB_CONTAINER_HOME}/.ssh

ifdef SSH_AUTH_SOCK
  CONTAINER_RUN_ARGS += -v ${SSH_AUTH_SOCK}:${OB_CONTAINER_HOME}/ssh.socket
  CONTAINER_RUN_ARGS += -e SSH_AUTH_SOCK=${OB_CONTAINER_HOME}/ssh.socket
endif

# Mount the repo directory as working directory.
CONTAINER_RUN_ARGS += -w ${OB_ROOT_DIR}
CONTAINER_RUN_ARGS += -v ${OB_ROOT_DIR}:${OB_ROOT_DIR}

# Export the required environment variables.
CONTAINER_RUN_ARGS += ${CONTAINER_ENV_VARIABLES}

# Mount the required volumes.
CONTAINER_RUN_ARGS += ${CONTAINER_VOLUMES}

# Add optional extra arguments.
CONTAINER_RUN_ARGS += ${OB_CONTAINER_RUN_EXTRA_ARGS}
