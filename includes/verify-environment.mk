# The sub makefiles must ensure that the required variables are available
# in the environment.

ifndef OB_TYPE
  $(error The variable OB_TYPE must be specified in the environment)
else ifneq ($(filter ${OB_TYPE},simple initenv yocto),${OB_TYPE})
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
else ifeq ($(realpath ${OB_DEFCONFIG_DIR}),)
  $(error The directory OB_DEFCONFIG_DIR must exist)
endif

ifndef OB_CONTAINER_DIR
  $(error The directory OB_CONTAINER_DIR must be specified in the environment)
else ifeq ($(realpath ${OB_CONTAINER_DIR}),)
  $(error The directory OB_CONTAINER_DIR must exist)
endif

ifneq ($(filter initenv yocto,${OB_TYPE}),)
  ifndef OB_INITENV_SCRIPT
    $(error The file OB_INITENV_SCRIPT must be specified in the environment)
  else ifeq ($(realpath ${OB_INITENV_SCRIPT}),)
    $(error The file OB_INITENV_SCRIPT must exist)
  endif
endif
