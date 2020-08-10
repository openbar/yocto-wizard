WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))..)

include ${WZDIR}/core/lib/config.mk
include ${WZDIR}/core/lib/submake.mk
include ${WZDIR}/core/lib/common.mk
include ${WZDIR}/core/lib/forward.mk

.forward:
	${MAKE_FORWARD} -f ${WZDIR}/core/config.mk
