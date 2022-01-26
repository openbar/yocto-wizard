WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

include ${WZDIR}/lib/config.mk
include ${WZDIR}/lib/submake.mk
include ${WZDIR}/lib/common.mk

$(call load-targets)

shell:
	${SHELL}
