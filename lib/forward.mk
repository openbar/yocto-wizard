${ALL_TARGETS}: .forward

.PHONY: .forward

MAKE_FORWARD := ${MAKE} ${MAKECMDGOALS}

trap = ${SHELL} -c "trap - ${1}; ${2}"
