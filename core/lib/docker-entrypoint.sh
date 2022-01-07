#!/bin/sh -e

# Add docker user and group
groupadd \
	--force \
	--non-unique \
	--gid ${DOCKER_GID:-911} \
	docker

useradd \
	--non-unique \
	--uid ${DOCKER_UID:-911} \
	--gid docker \
	${DOCKER_GROUPS:+--groups ${DOCKER_GROUPS}} \
	docker

# Execute the command as docker
su docker --command '"$0" "$@"' -- "$@"
