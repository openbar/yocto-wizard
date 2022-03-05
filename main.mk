# The main layer.
#
# The main layer is the entry point and is responsible for:
# - handling the command line options.
# - handling the default configuration targets.
# - handling the cleaning and help targets.
# - handling the special "foreach" target.
# - forwarding the other targets to the docker layer.

# The openbar directory. This must be done before any includes.
OPENBAR_DIR := $(realpath $(dir $(lastword ${MAKEFILE_LIST})))

# The base directory where the root makefile is located.
export REPO_DIR := ${CURDIR}

# Support the O= option in command line.
ifeq ($(origin O),command line)
  BUILD_DIR := $(abspath ${O})
endif

export BUILD_DIR ?= ${REPO_DIR}/build

# Support the V= option in command line.
ifeq ($(origin V),command line)
  ifneq ($(V),0)
    VERBOSE := $(V)
  endif
endif

export VERBOSE ?= 0

# All the required variables have been set.
# The common makefile can now be included.
include ${OPENBAR_DIR}/includes/common.mk

# Check if the "foreach" special target is used.
HAVE_FOREACH := $(filter foreach,${MAKECMDGOALS})

ifneq (${HAVE_FOREACH},)
  FOREACH_TARGETS := $(filter-out foreach,${MAKECMDGOALS})
endif

# Get the default configuration targets.
DEFCONFIG_TARGETS := $(sort $(notdir $(wildcard ${DEFCONFIG_DIR}/*_defconfig)))

# The targets that do not require to have a configuration file.
NO_CONFIG_TARGETS := ${DEFCONFIG_TARGETS} clean foreach ${FOREACH_TARGETS} help

# These targets must be declared as soon as possible. This way, the shell
# completion will work even if a configuration error occurs.
.PHONY: ${NO_CONFIG_TARGETS}
${NO_CONFIG_TARGETS}:

# Load the variables from the configuration:
# - if the configuration is required and no file is found, an error is thrown.
# - if the configuration is not required, ignore any configuration errors.
TARGETS := $(if $(MAKECMDGOALS),$(MAKECMDGOALS),all)

ifeq ($(realpath ${CONFIG}),)
  ifneq ($(filter-out ${NO_CONFIG_TARGETS},${TARGETS}),)
    $(info Please use one of the following configuration targets:)
    $(foreach target,${DEFCONFIG_TARGETS},$(info - ${target}))
    $(error Configuration file not found)
  endif
else
  ifeq ($(filter-out ${NO_CONFIG_TARGETS},${TARGETS}),)
    CONFIG_IGNORE_ERROR := yes
  endif

  $(call config-load-variables)
endif

ifneq (${HAVE_FOREACH},)
  # The "foreach" feature will execute the specified targets for each available
  # default configurations. The current configuration is kept and restored.
  .PHONY: ${FOREACH_TARGETS}
  ${FOREACH_TARGETS}: foreach

  .PHONY: foreach
  foreach:
	set -e; \
	if [ -f ${CONFIG} ]; then \
		mv ${CONFIG} ${CONFIG}.old; \
		trap "mv ${CONFIG}.old ${CONFIG}" EXIT; \
	else \
		trap "rm -f ${CONFIG}" EXIT; \
	fi; \
	for TARGET in ${DEFCONFIG_TARGETS}; do \
		${MAKE} $${TARGET} && ${MAKE} ${FOREACH_TARGETS}; \
	done
else
  # All configuration targets are forwarded to the docker layer.
  ifndef CONFIG_ERROR
    ifneq (${ALL_TARGETS},)
      ${ALL_TARGETS}: .forward

      .PHONY: .forward
      .forward:
	${MAKE} -f ${OPENBAR_DIR}/docker.mk ${MAKECMDGOALS}
    endif
  endif
endif

# The default configuration targets.
.PHONY: ${DEFCONFIG_TARGETS}
${DEFCONFIG_TARGETS}:
	@echo "Build configured for $@"
	install -C -m 644 ${DEFCONFIG_DIR}/$@ ${CONFIG}

# The "clean" target.
.PHONY: clean
clean:
	rm -rf ${BUILD_DIR}

# The "help" target.
.PHONY: help
help:
	@echo 'Generic targets:'
	@echo '  all                  - Build all targets marked with [*]'
	@echo
	@echo 'Configured targets:'
ifeq ($(realpath ${CONFIG}),)
	@echo '  Not yet configured'
else ifdef CONFIG_ERROR
	@echo '  Configuration error: ${CONFIG_ERROR}'
else ifeq (${ALL_TARGETS},)
	@echo '  No command defined'
else
	@$(foreach target,${AUTO_TARGETS},echo '* ${target}';)
	@$(foreach target,${MANUAL_TARGETS},echo '  ${target}';)
endif
	@echo
	@echo 'Configuration targets:'
	@$(foreach target,${DEFCONFIG_TARGETS},echo '  ${target}';)
	@echo
	@echo 'Cleaning targets:'
	@echo '  clean                - Remove the build directory'
	@echo
	@echo 'Usefull targets:'
	@echo '  help                 - Display this help'
	@echo '  foreach [targets]    - Build targets for each configuration'
	@echo
	@echo 'Command line options:'
	@echo '  make V=0-1 [targets] 0 => quiet build (default)'
	@echo '                       1 => verbose build'
	@echo '  make O=dir [targets] Use the specified build directory' \
		'(default: build)'
