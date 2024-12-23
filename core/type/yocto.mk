# The yocto layer.
#
# The yocto layer is responsible for:
# - exporting the required variables to bitbake.
# - cleaning the bitbake layer configuration.
# - adding the required bitbake layers.
# - validating the configured bitbake layers.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))/../..)

# The OE/Yocto variable used to export environment variables to bitbake.
OB_YOCTO_EXPORT_VARIABLE ?= BB_ENV_PASSTHROUGH_ADDITIONS

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

# Export all variables to the OE/Yocto environment.
export ${OB_YOCTO_EXPORT_VARIABLE} = ${OB_EXPORT}

# All targets are forwarded to the simple layer.
${OB_ALL_TARGETS}: .forward

.PHONY: .forward
.forward: .validate-layers
	$(call submake,type/simple.mk)

.PHONY: .validate-layers
.validate-layers: .add-layers
	${QUIET} bitbake-layers show-layers

.PHONY: .add-layers
.add-layers:
ifneq ($(strip ${OB_YOCTO_LAYERS}),)
	for LAYER in ${OB_YOCTO_LAYERS}; do \
		${QUIET} bitbake-layers add-layer -F $${LAYER}; \
	done
endif
