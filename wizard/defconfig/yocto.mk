DISTRO  := poky
MACHINE := qemux86-64

build:
	bitbake core-image-minimal

DL_DIR     ?= ${OB_ROOT_DIR}/downloads
SSTATE_DIR ?= ${OB_ROOT_DIR}/sstate-cache
