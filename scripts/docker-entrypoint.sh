#!/bin/sh -e

# Enable verbose
if [ ${OB_VERBOSE:-0} = 1 ]
then
	set -x
fi

# Add docker user and group
groupadd \
	--force \
	${OB_DOCKER_GID:+--non-unique --gid ${OB_DOCKER_GID}} \
	docker

useradd \
	${OB_DOCKER_UID:+--non-unique --uid ${OB_DOCKER_UID}} \
	--gid docker \
	${OB_DOCKER_GROUPS:+--groups ${OB_DOCKER_GROUPS}} \
	docker

# Execute the command as docker
if which sudo > /dev/null
then
	exec sudo --user docker \
		${OB_DOCKER_PRESERVE_ENV:+--preserve-env=${OB_DOCKER_PRESERVE_ENV}} \
		"$@"
else
	exec su docker --command '"$0" "$@"' -- "$@"
fi
