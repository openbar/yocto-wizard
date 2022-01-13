CONFIG := ${REPODIR}/.config

run-awk = $(shell ${MAKE} -npqf ${CONFIG} | awk -f ${WZDIR}/core/lib/${1})

empty :=

comma := ,
space := ${empty} ${empty}
verticaltab := ${empty}${empty}

define newline


endef

eval-awk = $(eval $(subst ${verticaltab},${newline},$(call run-awk,${1})))

load-targets = $(call eval-awk,targets.awk)
load-variables = $(call eval-awk,variables.awk)
