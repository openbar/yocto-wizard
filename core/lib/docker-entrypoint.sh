#!/bin/sh -e

# Add docker user and group
groupadd \
	--force \
	${DOCKER_GID:+--non-unique --gid ${DOCKER_GID}} \
	docker

useradd \
	${DOCKER_UID:+--non-unique --uid ${DOCKER_UID}} \
	--gid docker \
	${DOCKER_GROUPS:+--groups ${DOCKER_GROUPS}} \
	docker

# Execute the command as docker
su docker --command '"$0" "$@"' -- "$@"