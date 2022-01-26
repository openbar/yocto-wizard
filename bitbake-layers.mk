WIZARD_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

include ${WIZARD_DIR}/lib/config.mk
include ${WIZARD_DIR}/lib/submake.mk
include ${WIZARD_DIR}/lib/common.mk
include ${WIZARD_DIR}/lib/forward.mk

.PHONY: .add-layers
.add-layers:
ifneq ($(strip ${BB_LAYERS}),)
	bitbake-layers add-layer -q ${BB_LAYERS}
endif

.PHONY: .validate-layers
.validate-layers: .add-layers
	bitbake-layers show-layers -q

.forward: .validate-layers
	${MAKE_FORWARD} -f ${WIZARD_DIR}/config.mk
