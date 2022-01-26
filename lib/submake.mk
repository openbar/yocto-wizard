ifndef REPO_DIR
 $(error The directory REPO_DIR must be specified)
else ifeq ($(realpath ${REPO_DIR}),)
 $(error The directory REPO_DIR must exist)
endif

ifndef BUILD_DIR
 $(error The directory BUILD_DIR must be specified)
endif

ifndef VERBOSE
 $(error The variable VERBOSE must be specified)
endif

ifndef CONFIG
 $(error The variable CONFIG must be specified)
else ifeq ($(realpath ${CONFIG}),)
 $(error The CONFIG file must exist)
endif
