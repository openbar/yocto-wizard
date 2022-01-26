WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

include ${WZDIR}/lib/config.mk
include ${WZDIR}/lib/submake.mk
include ${WZDIR}/lib/common.mk
include ${WZDIR}/lib/forward.mk

OE_INIT_BUILD_ENV ?= platform/poky/oe-init-build-env

override BB_EXPORT_VARIABLES += ${DEFAULT_BB_EXPORT_VARIABLES}

define export-variable
 ifdef ${1}
  export ${1}
  export BB_ENV_EXTRAWHITE += ${1}
 endif
endef

$(foreach variable,$(sort ${BB_EXPORT_VARIABLES}),\
	$(eval $(call export-variable,${variable})))

.PHONY: .clean-bblayers
.clean-bblayers:
	rm -f ${BUILDDIR}/conf/bblayers.conf

.PHONY: .oe-init-build-env
.oe-init-build-env: .clean-bblayers
	${QUIET} . ${OE_INIT_BUILD_ENV} ${BUILDDIR} \
		&& ${MAKE_FORWARD} -f ${WZDIR}/bitbake-layers.mk

.forward: .oe-init-build-env
