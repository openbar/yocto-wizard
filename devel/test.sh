#!/bin/sh -e

cd "${0%/*}"

export OB_VAR1=var1

export OB_EXPORT=VAR2
export VAR2=var2

for CONTAINER in podman docker; do
	for TYPE in simple initenv yocto; do
		echo "\033[0;33m${CONTAINER} - ${TYPE}\033[0m"
		OB_CONTAINER_ENGINE=${CONTAINER} make --no-print-directory -C test/${TYPE} VAR3=var3 $@
	done
done

echo "\033[0;32mOK\033[0m"
