WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))..)

include ${WZDIR}/core/lib/config.mk
include ${WZDIR}/core/lib/submake.mk
include ${WZDIR}/core/lib/common.mk

$(call load-targets)
