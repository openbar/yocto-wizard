# The oe-init-build-env layer.
#
# The oe-init-build-env layer is responsible for:
# - cleaning the bitbake layer configuration.
# - initializing the bitbake environment.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))/../..)

# Include the common makefiles.
include ${OPENBAR_DIR}/includes/verify-environment.mk
include ${OPENBAR_DIR}/includes/common.mk

# Load the configuration variables and targets.
ifeq ($(realpath ${CONFIG}),)
  $(error Configuration file not found)
else
  $(call config-load-variables)
endif

# All targets are forwarded to the bitbake-layers layer.
${OB_ALL_TARGETS}: .forward

.PHONY: .forward
.forward:
	${QUIET} . ${OB_BB_INIT_BUILD_ENV} ${OB_BUILD_DIR} \
		&& ${MAKE} -f ${OPENBAR_DIR}/core/bitbake-layers.mk ${MAKECMDGOALS}
