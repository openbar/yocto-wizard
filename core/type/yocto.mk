# The bitbake-layers layer.
#
# The bitbake-layers layer is responsible for:
# - adding the required bitbake layers.
# - validating the configured bitbake layers.

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

# All targets are forwarded to the config layer.
${OB_ALL_TARGETS}: .forward

.PHONY: .forward
.forward: .validate-bitbake-layers
	${MAKE} -f ${OPENBAR_DIR}/core/config.mk ${MAKECMDGOALS}

.PHONY: .validate-bitbake-layers
.validate-bitbake-layers: .add-bitbake-layers
	${QUIET} bitbake-layers show-layers

.PHONY: .add-bitbake-layers
.add-bitbake-layers:
ifneq ($(strip ${OB_BB_LAYERS}),)
	for LAYER in ${OB_BB_LAYERS}; do \
		${QUIET} bitbake-layers add-layer -F $${LAYER}; \
	done
endif
