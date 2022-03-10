# The sub makefiles must ensure that the required variables are available
# in the environment.

ifndef OB_TYPE
  $(error The variable OB_TYPE must be specified in the environment)
else ifneq ($(filter ${OB_TYPE},standard yocto),${OB_TYPE})
  $(error Invalid value for OB_TYPE: ${OB_TYPE})
endif

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
 $(error The directory OB_DEFCONFIG_DIR must be specified in the environment)
endif

ifndef OB_DOCKER_DIR
 $(error The directory OB_DOCKER_DIR must be specified in the environment)
endif

ifeq (${OB_TYPE},yocto)
  ifndef OB_BB_INIT_BUILD_ENV
   $(error The file OB_BB_INIT_BUILD_ENV must be specified in the environment)
  endif
endif
