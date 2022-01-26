CONFIG := ${REPO_DIR}/.config

MAKE_AWK := ${MAKE}
MAKE_AWK += REPO_DIR=${REPO_DIR}
MAKE_AWK += BUILD_DIR=${BUILD_DIR}
MAKE_AWK += VERBOSE=${VERBOSE}

run-awk = $(shell ${MAKE_AWK} -npqf ${CONFIG} 2>&1 | awk -f ${WIZARD_DIR}/lib/${1})

empty :=

comma := ,
space := ${empty} ${empty}
verticaltab := ${empty}${empty}

define newline


endef

eval-awk = $(eval $(subst ${verticaltab},${newline},$(call run-awk,${1})))

load-targets = $(call eval-awk,targets.awk)
load-variables = $(call eval-awk,variables.awk)
