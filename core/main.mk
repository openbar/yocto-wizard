WZDIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST}))..)

REPODIR := ${CURDIR}

# Support the O= option in command line.
ifeq ($(origin O),command line)
 BUILDDIR := $(abspath ${O})
endif

BUILDDIR ?= ${REPODIR}/build

include ${WZDIR}/core/lib/config.mk

DEFCONFIGDIR := ${WZDIR}/configs

DEFCONFIG_TARGETS := $(sort $(notdir $(wildcard ${DEFCONFIGDIR}/*_defconfig)))

TARGETS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),all)

NO_DEFCONFIG_TARGETS := ${DEFCONFIG_TARGETS} clean help

ifneq ($(filter-out ${NO_DEFCONFIG_TARGETS},${TARGETS}),)
 ifeq ($(realpath ${CONFIG}),)
  $(warning Configuration file not found)
  $(info Please use one of the following configuration targets:)
  $(foreach TARGET,${DEFCONFIG_TARGETS},$(info - ${TARGET}))
 endif
endif

# Support the V= option in command line.
ifeq ($(origin V),command line)
 ifneq ($(V),0)
  VERBOSE := $(V)
 endif
endif

VERBOSE ?= 0

include ${WZDIR}/core/lib/common.mk
include ${WZDIR}/core/lib/forward.mk

.forward:
	${MAKE_FORWARD} -f ${WZDIR}/core/docker.mk

.PHONY: ${DEFCONFIG_TARGETS}
${DEFCONFIG_TARGETS}:
	install -C -m 644 ${DEFCONFIGDIR}/$@ ${CONFIG}

.PHONY: clean
clean:
	rm -rf ${BUILDDIR}

.PHONY: help
help::
	@echo 'Generic targets:'
	@echo '  all                  - Build all targets marked with [*]'
	@echo
	@echo 'Configured targets:'

ifeq ($(realpath ${CONFIG}),)
 help::
	@echo '  Not yet configured'
else ifneq (${ALL_TARGETS},)
 $(foreach TARGET,${AUTO_TARGETS},$(eval help:: ; @echo '* ${TARGET}'))
 $(foreach TARGET,${MANUAL_TARGETS},$(eval help:: ; @echo '  ${TARGET}'))
else
 help::
	@echo '  No command defined'
endif

help::
	@echo
	@echo 'Configuration targets:'
$(foreach TARGET,${DEFCONFIG_TARGETS},$(eval help:: ; @echo '  ${TARGET}'))

help::
	@echo
	@echo 'Cleaning targets:'
	@echo '  clean                - Remove the build directory'
	@echo
	@echo 'Usefull targets:'
	@echo '  help                 - Display this help'
	@echo
	@echo 'Command line options:'
	@echo '  make V=0-1 [targets] 0 => quiet build (default)'
	@echo '                       1 => verbose build'
	@echo '  make O=dir [targets] Use the specified build directory' \
		'(default: build)'
