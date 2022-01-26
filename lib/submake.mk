ifndef REPODIR
 $(error The directory REPODIR must be specified)
else ifeq ($(realpath ${REPODIR}),)
 $(error The directory REPODIR must exist)
endif

ifndef BUILDDIR
 $(error The directory BUILDDIR must be specified)
endif

ifndef VERBOSE
 $(error The variable VERBOSE must be specified)
endif

ifndef CONFIG
 $(error The variable CONFIG must be specified)
else ifeq ($(realpath ${CONFIG}),)
 $(error The CONFIG file must exist)
endif
