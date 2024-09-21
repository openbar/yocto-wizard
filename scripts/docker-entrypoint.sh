#!/bin/sh
# shellcheck shell=sh enable=all

# Enable verbose
if [ "${OB_VERBOSE:-0}" = 1 ]; then
	set -x
fi

ADDGROUP=$(command -v addgroup)
ADDGROUP_BUSYBOX=$(readlink -f "${ADDGROUP}" | grep busybox)
ADDUSER=$(command -v adduser)
ADDUSER_BUSYBOX=$(readlink -f "${ADDUSER}" | grep busybox)
GROUPADD=$(command -v groupadd)
RUNUSER=$(command -v runuser)
SU=$(command -v su)
SUDO=$(command -v sudo)
USERADD=$(command -v useradd)
USERMOD=$(command -v usermod)

# Failures are no longer allowed
set -e

# Create the docker group
if [ -n "${GROUPADD}" ]; then
	groupadd -f ${OB_DOCKER_GID:+-o -g ${OB_DOCKER_GID}} docker

elif [ -n "${ADDGROUP_BUSYBOX}" ]; then
	addgroup ${OB_DOCKER_GID:+-g ${OB_DOCKER_GID}} docker

elif [ -n "${ADDGROUP}" ]; then
	addgroup ${OB_DOCKER_GID:+--gid ${OB_DOCKER_GID}} docker

else
	echo >&2 "Failed to add docker group"
	exit 1
fi

# Create the docker user
mkdir -p "${OB_DOCKER_HOME:=/home/container}"

if [ -n "${USERADD}" ]; then
	useradd -d "${OB_DOCKER_HOME}" -M \
		${OB_DOCKER_UID:+-o -u ${OB_DOCKER_UID}} \
		-g docker docker

elif [ -n "${ADDUSER_BUSYBOX}" ]; then
	adduser -h "${OB_DOCKER_HOME}" -H \
		${OB_DOCKER_UID:+-u ${OB_DOCKER_UID}} \
		-G docker -D docker

elif [ -n "${ADDUSER}" ]; then
	adduser --home "${OB_DOCKER_HOME}" --no-create-home \
		${OB_DOCKER_UID:+--uid ${OB_DOCKER_UID}} \
		--ingroup docker docker

else
	echo >&2 "Failed to add docker user"
	exit 1
fi

# Add docker user to extra groups
for GROUP in ${OB_DOCKER_GROUPS:-}; do
	if [ -n "${USERMOD}" ]; then
		usermod -a -G "${GROUP}" docker

	elif [ -n "${ADDUSER}" ]; then
		adduser docker "${GROUP}"

	else
		echo >&2 "Failed to add docker user to ${GROUP} group"
		exit 1
	fi
done

# Adjust rights for the user home
chown docker:docker "${OB_DOCKER_HOME}"

# Execute the command as docker
if [ -n "${RUNUSER}" ]; then
	exec runuser -u docker -- "$@"

elif [ -n "${SUDO}" ]; then
	exec sudo -E -u docker "$@"

elif [ -n "${SU}" ]; then
	exec su docker -c "$*"

else
	echo >&2 "Failed to switch to docker user"
	exit 1
fi
