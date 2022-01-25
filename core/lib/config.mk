CONFIG := ${REPODIR}/.config

MAKE_AWK := ${MAKE}
MAKE_AWK += REPODIR=${REPODIR}
MAKE_AWK += BUILDDIR=${BUILDDIR}
MAKE_AWK += VERBOSE=${VERBOSE}

run-awk = $(shell ${MAKE_AWK} -npqf ${CONFIG} 2>&1 | awk -f ${WZDIR}/core/lib/${1})

empty :=

comma := ,
space := ${empty} ${empty}
verticaltab := ${empty}${empty}

define newline


endef

eval-awk = $(eval $(subst ${verticaltab},${newline},$(call run-awk,${1})))

load-targets = $(call eval-awk,targets.awk)
load-variables = $(call eval-awk,variables.awk)
