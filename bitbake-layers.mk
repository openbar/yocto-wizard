WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

include ${WZDIR}/lib/config.mk
include ${WZDIR}/lib/submake.mk
include ${WZDIR}/lib/common.mk
include ${WZDIR}/lib/forward.mk

.PHONY: .add-layers
.add-layers:
ifneq ($(strip ${BBLAYERS}),)
	bitbake-layers add-layer -q ${BBLAYERS}
endif

.PHONY: .validate-layers
.validate-layers: .add-layers
	bitbake-layers show-layers -q

.forward: .validate-layers
	${MAKE_FORWARD} -f ${WZDIR}/config.mk
