# The sub makefiles must ensure that the required variables are available
# in the environment.

ifndef OB_ROOT_DIR
  $(error The directory OB_ROOT_DIR must be specified in the environment)
else ifeq ($(realpath ${OB_ROOT_DIR}),)
  $(error The directory OB_ROOT_DIR must exist)
endif

ifndef OB_BUILD_DIR
 $(error The directory OB_BUILD_DIR must be specified in the environment)
endif

ifndef OB_VERBOSE
 $(error The variable OB_VERBOSE must be specified in the environment)
endif

ifndef OB_DEFCONFIG_DIR
 $(error The variable OB_DEFCONFIG_DIR must be specified in the environment)
endif

ifndef OB_DOCKER_DIR
 $(error The variable OB_DOCKER_DIR must be specified in the environment)
endif

ifndef OB_BB_INIT_BUILD_ENV
 $(error The variable OB_BB_INIT_BUILD_ENV must be specified in the environment)
endif
