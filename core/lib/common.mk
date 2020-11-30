MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

ifneq ($(realpath ${CONFIG}),)
 $(call load-variables)
endif

AUTO_TARGETS := $(filter-out ${MANUAL_TARGETS},${ALL_TARGETS})

.PHONY: all ${ALL_TARGETS}
all: ${AUTO_TARGETS}
