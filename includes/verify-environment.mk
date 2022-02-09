# The sub makefiles must ensure that the required variables are available
# in the environment.

ifndef REPO_DIR
  $(error The directory REPO_DIR must be specified in the environment)
else ifeq ($(realpath ${REPO_DIR}),)
  $(error The directory REPO_DIR must exist)
endif

ifndef BUILD_DIR
 $(error The directory BUILD_DIR must be specified in the environment)
endif

ifndef VERBOSE
 $(error The variable VERBOSE must be specified in the environment)
endif

ifndef DEFCONFIG_DIR
 $(error The variable DEFCONFIG_DIR must be specified in the environment)
endif

ifndef DOCKER_DIR
 $(error The variable DOCKER_DIR must be specified in the environment)
endif

ifndef OE_INIT_BUILD_ENV
 $(error The variable OE_INIT_BUILD_ENV must be specified in the environment)
endif
