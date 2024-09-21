# Disable printing of the working directory.
MAKEFLAGS += --no-print-directory

# That's our default target when none is given on the command line.
.PHONY: all
all:

# Keep the openbar silent if requested.
ifeq (${OB_VERBOSE},0)
  MAKEFLAGS += --silent
  QUIET := >/dev/null
endif

# Useful variables.
DIGIT := 0 1 2 3 4 5 6 7 8 9
LOWER := a b c d e f g h i j k l m n o p q r s t u v w x y z
UPPER := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z

ALPHA := ${LOWER} ${UPPER}
ALNUM := ${ALPHA} ${DIGIT}

EMPTY       :=
COMMA       := ,
COLON       := :
SPACE       := ${EMPTY} ${EMPTY}
VERTICALTAB := ${EMPTY}${EMPTY}

define NEWLINE :=


endef

# The configuration file.
CONFIG := ${OB_ROOT_DIR}/.config

# The container home directory.
OB_CONTAINER_HOME := /home/container

## notfirstword <list>
# Return all elements of the list except the first one.
notfirstword = $(wordlist 2,$(words ${1}),${1})

## splitstr <string>
# Split the string into list of characters.
# Inspired by the GNU Make Standard Library: https://github.com/jgrahamc/gmsl
splitstr_r = $(if ${1},$(call splitstr_r,$(call notfirstword,${1}),$(subst $(firstword ${1}),${SPACE}$(firstword ${1}),${2})),${2})
splitstr = $(call splitstr_r,${ALNUM},${1})

# The MAKEFLAGS to be used for sub-makefiles.
SUBMAKEFLAGS  = $(filter s,$(call splitstr,$(filter-out -%,$(firstword ${MAKEFLAGS}))))
SUBMAKEFLAGS += $(filter -j% --no-print-directory,${MAKEFLAGS})

# The arguments to be used for sub-makefiles.
SUBMAKEARGS = $(patsubst %,-%,$(patsubst -%,%,${SUBMAKEFLAGS}))

## submake <makefile>
# Call a sub-makefile inside the core directory.
submake_noenv = ${MAKE} ${SUBMAKEARGS}  -f ${OPENBAR_DIR}/core/${1} ${MAKECMDGOALS}
submake = MAKEFLAGS= $(call submake_noenv,${1})

## foreach-eval <list> <function>
# For each unique element of the <list>, evaluate the specified <function> call.
foreach-eval = $(foreach element,$(sort ${1}),$(eval $(call ${2},${element})))

# Add all public variables to the export list.
override OB_EXPORT += $(filter OB_%,${.VARIABLES})

# Add OE/Yocto related variables to the export list.
ifeq (${OB_TYPE},yocto)
  override OB_EXPORT += DEPLOY_DIR DL_DIR SSTATE_DIR
  override OB_EXPORT += DISTRO MACHINE
  override OB_EXPORT += OB_YOCTO_EXPORT_VARIABLE OB_YOCTO_LAYERS
endif

# Ensure that values in OB_EXPORT are sorted and unique.
override OB_EXPORT := $(sort ${OB_EXPORT})

# Export all variables from the export list.
define export-variable
  ifdef ${1}
    export ${1}
  endif
endef

$(call foreach-eval,${OB_EXPORT},export-variable)

# To interpret and analyze the configuration file, it is read as a makefile.
# Its database (the resulting variables and targets) is printed (option -p).
# The same approach is used by /usr/share/bash-completion/completions/make.
#
# The $(shell) function is used to make the call. But the $(shell) invoked does
# not inherit the internal environment. And therefore, is not able to see the
# internal variables (like OB_ROOT_DIR).
#
# So each variables which needs to be exported have to be added in the command
# line. The OB_EXPORT variable lists all the variables that will need to be
# exported. This variable can be appended by the user.
CONFIG_MAKE := ${MAKE} MAKE=true

define export-variable-config
  ifdef ${1}
    CONFIG_MAKE += ${1}="${${1}}"
  endif
endef

$(call foreach-eval,${OB_EXPORT},export-variable-config)

## config-parse <script>
# Parse the configuration file using a specified <script>.
#
# The output uses the makefile format so it can be evaluated directly.
#
# By default the $(shell) function replaces newline characters with spaces.
# So the script is using vertical tabs as separators, that are replaced by
# newlines later.
config-parse = $(subst ${VERTICALTAB},${NEWLINE},$(shell LC_ALL=C ${CONFIG_MAKE} -rRnpqf ${CONFIG} 2>&1 | awk -f ${1}))

## config-load-variables
# Load the variables from the configuration (and not the targets).
#
# The OB_ALL_TARGETS list the available targets from the configuration. The
# internal "shell" target is added manually.
#
# The OB_MANUAL_TARGETS is a user configurable variable. The OB_AUTO_TARGETS is
# automatically deducted from the previous OB_*_TARGETS variables.
#
# The OB_AUTO_TARGETS are added as dependencies of the "all" target.
define config-load-variables-noeval
  $(call config-parse,${OPENBAR_DIR}/scripts/config-variables.awk)

  OB_ALL_TARGETS += shell
  OB_MANUAL_TARGETS += shell

  OB_AUTO_TARGETS := $$(filter-out $${OB_MANUAL_TARGETS},$${OB_ALL_TARGETS})

  .PHONY: $${OB_ALL_TARGETS}

  all: $${OB_AUTO_TARGETS}
endef

config-load-variables = $(eval $(call config-load-variables-noeval))

## config-load-targets
# Load the targets from the configuration (and not the variables).
define config-load-targets-noeval
  $(call config-parse,${OPENBAR_DIR}/scripts/config-targets.awk)
endef

config-load-targets = $(eval $(call config-load-targets-noeval))
