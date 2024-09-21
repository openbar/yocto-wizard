# The initenv layer.
#
# The initenv layer is responsible for:
# - initializing the environment.
# - forwarding the other targets to another type layer.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))/../..)

# Include the common makefiles.
include ${OPENBAR_DIR}/includes/verify-environment.mk
include ${OPENBAR_DIR}/includes/common.mk
include ${OPENBAR_DIR}/includes/type.mk

# Load the configuration variables.
ifeq ($(realpath ${CONFIG}),)
  $(error Configuration file not found)
else
  $(call config-load-variables)
endif

# All targets are forwarded to another type layer.
${OB_ALL_TARGETS}: .forward

ifeq (${OB_TYPE},yocto)
  NEXT_LAYER := type/yocto.mk
else
  NEXT_LAYER := type/simple.mk
endif

.PHONY: .forward
.forward:
	${QUIET} . ${OB_INITENV_SCRIPT} ${OB_BUILD_DIR} \
		&& $(call submake,${NEXT_LAYER})
