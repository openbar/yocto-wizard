# The oe-init-build-env layer.
#
# The oe-init-build-env layer is responsible for:
# - exporting the required variables to bitbake.
# - cleaning the bitbake layer configuration.
# - initializing the bitbake environment.

# The wizard directory. This must be done before any includes.
WIZARD_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

# Include the common makefiles.
include ${WIZARD_DIR}/includes/verify-environment.mk
include ${WIZARD_DIR}/includes/common.mk

# Load the configuration variables and targets.
ifeq ($(realpath ${CONFIG}),)
  $(error Configuration file not found)
else
  $(call config-load-variables)
endif

# Export the required variables to bitbake.
override BB_EXPORT_VARIABLES += REPO_DIR BUILD_DIR VERBOSE
override BB_EXPORT_VARIABLES += DL_DIR SSTATE_DIR DISTRO MACHINE

define export-variable
  ifdef ${1}
    export ${1}
    export BB_ENV_EXTRAWHITE += ${1}
  endif
endef

$(call foreach-eval,${BB_EXPORT_VARIABLES},export-variable)

# All targets are forwarded to the bitbake-layers layer.
${ALL_TARGETS}: .forward

.PHONY: .forward
.forward: .clean-bblayers
	${QUIET} . ${OE_INIT_BUILD_ENV} ${BUILD_DIR} \
		&& ${MAKE} -f ${WIZARD_DIR}/bitbake-layers.mk ${MAKECMDGOALS}

# The configuration of the bitbake layers must be removed. It will then be
# rebuilt each time by the following bitbake-layers layer.
.PHONY: .clean-bblayers
.clean-bblayers:
	rm -f ${BUILD_DIR}/conf/bblayers.conf