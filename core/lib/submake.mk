ifneq ($(origin REPODIR),command line)
 $(error The directory REPODIR must be specified in the command line)
else ifeq ($(realpath ${REPODIR}),)
 $(error The directory REPODIR must exist)
endif

ifneq ($(origin BUILDDIR),command line)
 $(error The directory BUILDDIR must be specified in the command line)
endif

ifeq ($(realpath ${CONFIG}),)
 $(error The CONFIG file must exist)
endif
