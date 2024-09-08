# The configuration layer. This layer is the last one.
#
# The environment is fully set up and the last thing to do is to parse the
# configuration file including targets, so they can be called.
#
# The shell target is added to allow access to the build environment for debug
# and development purpose.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))/..)

# Include the common makefiles.
include ${OPENBAR_DIR}/includes/verify-environment.mk
include ${OPENBAR_DIR}/includes/common.mk

# Load the configuration variables and targets.
ifeq ($(realpath ${CONFIG}),)
  $(error Configuration file not found)
else
  $(call config-load-variables)
  $(call config-load-targets)
endif

# Add the "shell" target.
shell:
	${SHELL}
