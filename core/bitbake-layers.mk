WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))..)

include ${WZDIR}/core/lib/config.mk
include ${WZDIR}/core/lib/submake.mk
include ${WZDIR}/core/lib/common.mk
include ${WZDIR}/core/lib/forward.mk

.PHONY: .add-layers
.add-layers:
ifneq (${BBLAYERS},)
	bitbake-layers add-layer -q ${BBLAYERS}
endif

.PHONY: .validate-layers
.validate-layers: .add-layers
	bitbake-layers show-layers -q

.forward: .validate-layers
	${MAKE_FORWARD} -f ${WZDIR}/core/config.mk
