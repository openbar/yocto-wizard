# OE/Yocto requires the use of bash(1).
ifeq (${OB_TYPE},yocto)
  export SHELL := /bin/bash
endif
