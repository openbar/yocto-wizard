WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))..)

include ${WZDIR}/core/lib/config.mk
include ${WZDIR}/core/lib/submake.mk
include ${WZDIR}/core/lib/common.mk
include ${WZDIR}/core/lib/forward.mk

OE_INIT_BUILD_ENV ?= platform/poky/oe-init-build-env

BB_EXPORT_VARIABLES := REPODIR BUILDDIR DL_DIR SSTATE_DIR DISTRO MACHINE

define export-variable
 ifdef ${1}
  export ${1}
  export BB_ENV_EXTRAWHITE += ${1}
 endif
endef

$(foreach variable,${BB_EXPORT_VARIABLES},\
	$(eval $(call export-variable,${variable})))

.PHONY: .clean-bblayers
.clean-bblayers:
	rm -f ${BUILDDIR}/conf/bblayers.conf

.PHONY: .oe-init-build-env
.oe-init-build-env: .clean-bblayers
	${QUIET} . ${OE_INIT_BUILD_ENV} ${BUILDDIR} \
		&& ${MAKE_FORWARD} -f ${WZDIR}/core/bitbake-layers.mk

.forward: .oe-init-build-env
