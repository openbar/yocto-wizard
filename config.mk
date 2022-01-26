WIZARD_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

include ${WIZARD_DIR}/lib/config.mk
include ${WIZARD_DIR}/lib/submake.mk
include ${WIZARD_DIR}/lib/common.mk

$(call load-targets)

shell:
	${SHELL}
