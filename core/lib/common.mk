MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables
MAKEFLAGS += --no-print-directory

ifeq (${VERBOSE},0)
 MAKEFLAGS += --silent
 QUIET := >/dev/null
endif

ifneq ($(realpath ${CONFIG}),)
 $(call load-variables)
endif

ALL_TARGETS += shell
MANUAL_TARGETS += shell

AUTO_TARGETS := $(filter-out ${MANUAL_TARGETS},${ALL_TARGETS})

.PHONY: all ${ALL_TARGETS}
all: ${AUTO_TARGETS}

SHELL := /bin/bash

export PROJECT := $(notdir ${REPODIR})
