#!/bin/sh
# vi: ft=sh
# shellcheck shell=sh enable=all

OB_VERSION=${1:-1a8be9fcf201942a72b273bff01c4f5fbfff80a5}
OB_REPOSITORY_NWO=openbar/openbar
OB_REPOSITORY_URL=https://github.com/openbar/openbar

# Colorize the output
red() { printf "\033[0;31m%s\033[0m\n" "${*}"; }
green() { printf "\033[0;32m%s\033[0m\n" "${*}"; }
yellow() { printf "\033[0;33m%s\033[0m\n" "${*}"; }

# Create the temporary directory
TMP_DIR=$(mktemp -d)

# Exit handler
on_exit() {
	EXIT_STATUS=${1:-$?}

	# Remove the temporary directory
	rm -rf "${TMP_DIR}"

	# Print a status line
	if [ "${EXIT_STATUS}" -eq 0 ]; then
		echo
		green "Openbar project generation done"
	else
		printf >&2 "\n\n"
		red >&2 "Openbar project generation aborted"
	fi

	exit "${EXIT_STATUS}"
}

# Ensure the exit handler is always called
# https://unix.stackexchange.com/a/240736/117394
on_sigint() {
	trap - INT EXIT
	on_exit 1
	kill -s INT $$
}

trap on_sigint INT
trap on_exit EXIT

## ask <question> [prompt]
ask() {
	QUESTION=$(yellow "${1}")
	printf >&2 "%s%s " "${QUESTION}" "${2:+ ${2}}"
}

## ask_yesno <question> [default=yes]
ask_yesno() {
	DEFAULT="${2:-yes}"

	[ "${DEFAULT}" = yes ] && PROMPT="[Y/n]" || PROMPT="[y/N]"

	while true; do
		echo >&2
		ask "${1}" "${PROMPT}"

		read -r YESNO

		case "${YESNO}" in
		"") [ "${DEFAULT}" = yes ] && return 0 || return 1 ;;
		[yY] | [yY][eE][sS]) return 0 ;;
		[nN] | [nN][oO]) return 1 ;;
		*) red >&2 "Invalid response: ${YESNO}" ;;
		esac
	done
}

## ask_value <question> [default]
ask_value() {
	DEFAULT="${2}"

	[ -n "${DEFAULT}" ] && PROMPT=" [${DEFAULT}]" || PROMPT=""

	while true; do
		echo >&2
		ask "${1}" "${PROMPT}"

		read -r VALUE

		if [ -z "${VALUE:-${DEFAULT}}" ]; then
			red >&2 "Invalid empty response"
		else
			echo "${VALUE:-${DEFAULT}}"
			return 0
		fi
	done
}

## ask_select <question> <colon-list> [default=1]
ask_select() {
	## print_list <colon-list>
	print_list() {
		echo "${1}" | awk -F: '{
			for (i = 1; i <= NF; i++) {
				printf("%2s) %s\n", i, $i) > "/dev/stderr";
			}
		}'
	}

	## check_value <colon-list> <value> [default=1]
	check_value() {
		echo "${1}" | awk -F: -v VALUE="${2:-${3:-1}}" '{
			LCVALUE = tolower(VALUE);
			for (i = 1; i <= NF; i++) {
				if (LCVALUE == i || LCVALUE == $i) {
					printf("%s", $i);
					exit;
				}
			}
		}'
	}

	DEFAULT=$(check_value "${2}" "${3:-1}")

	while true; do
		echo >&2
		print_list "${2}"
		ask "${1}" "[${DEFAULT}]"

		read -r VALUE

		SAFE_VALUE=$(check_value "${2}" "${VALUE}" "${DEFAULT}")

		if [ -z "${SAFE_VALUE}" ]; then
			red >&2 "Invalid response: ${VALUE}"
		else
			echo "${SAFE_VALUE}"
			return 0
		fi
	done
}

## sanitize <option>...
sanitize() {
	VALUE="$(cat)"

	# Protect against CTRL-D
	if [ -z "${VALUE}" ]; then
		red >&2 "Invalid empty value"
		exit 1
	fi

	for OPTION in "${@}"; do
		unset PROMPT_NEQ
		unset PROMPT

		OLD_VALUE="${VALUE}"

		case ${OPTION} in

		onlyprint)
			PROMPT_NEQ="Only printable character allowed"
			VALUE=$(echo "${VALUE}" | sed -e "s/[^[[:print:]]]//g")
			;;

		noslash)
			PROMPT_NEQ="Slash character not allowed"
			VALUE=$(echo "${VALUE}" | sed -e "s:/::g")
			;;

		noleadingslash)
			PROMPT_NEQ="Leading slash character not allowed"
			VALUE=$(echo "${VALUE}" | sed -e "s:^/::")
			;;

		notrailingslash)
			PROMPT_NEQ="Trailing slash character not allowed"
			VALUE=$(echo "${VALUE}" | sed -e "s:/$::")
			;;

		nospace)
			PROMPT_NEQ="Space character not allowed"
			VALUE=$(echo "${VALUE}" | sed -e "s/[[:space:]]//g")
			;;

		trailingdefconfig)
			PROMPT_NEQ="Trailing '_defconfig' is mandatory"
			VALUE=$(echo "${VALUE}" | sed -e "s/_defconfig$//" -e "s/$/_defconfig/")
			;;

		preferedlower)
			echo "${VALUE}" | grep -q "[[:upper:]]" &&
				PROMPT="Using lowercase characters is recommended"
			;;

		*)
			PROMPT="Invalid option ${OPTION}"
			;;
		esac

		if [ -n "${PROMPT_NEQ}" ] && [ "${OLD_VALUE}" != "${VALUE}" ]; then
			PROMPT=$(red "${PROMPT_NEQ}:")
			echo >&2 "${PROMPT} '${OLD_VALUE}' -> '${VALUE}'"

		elif [ -n "${PROMPT}" ]; then
			red >&2 "${PROMPT}"
		fi
	done

	echo "${VALUE}"
}

### create_file <filename> (content is in stdin)
#create_file() {
#	mkdir -p "${1%/*}"
#	cat >"${1}"
#}
#
### create_dockerfile_xxx <directory>
#create_dockerfile_simple() {
#	create_file "${1}/container/default/Dockerfile" <<-EOF
#		FROM docker.io/alpine
#
#		RUN set -x \
#			&& apk add --no-cache bash gawk make
#	EOF
#}
#
#create_dockerfile_initenv() {
#	create_dockerfile_simple "${1}"
#}
#
#create_dockerfile_yocto() {
#	create_file "${1}/container/default/Dockerfile" <<-EOF
#		FROM debian:bookworm-slim
#
#		ENV LANG en_US.utf8
#
#		RUN set -x \
#			&& export DEBIAN_FRONTEND=noninteractive \
#			&& apt update \
#			&& apt install --no-install-recommends -y \
#				build-essential \
#				ca-certificates \
#				chrpath \
#				cpio \
#				diffstat \
#				file \
#				gawk \
#				git \
#				locales \
#				lz4 \
#				python3 \
#				wget \
#				zstd \
#			&& rm -rf /var/lib/apt/lists/* \
#			&& sed -i 's:^# \(en_US.UTF-8 UTF-8\):\1:g' /etc/locale.gen \
#			&& locale-gen
#	EOF
#}
#
### create_defconfig_xxx <directory>
#create_defconfig_simple() {
#	create_file "${1}/${OB_DEFCONFIG_FILE}" <<-EOF
#		build:
#			echo "Nothing to do"
#	EOF
#}
#
#create_defconfig_initenv() {
#	create_defconfig_simple "${1}"
#}
#
#create_defconfig_yocto() {
#	create_file "${1}/${OB_DEFCONFIG_FILE}" <<-"EOF"
#		DISTRO  := poky
#		IMAGE   := core-image-minimal
#		MACHINE := qemux86-64
#
#		build:
#			bitbake ${IMAGE}
#
#		OB_MANUAL_TARGETS += clean
#		clean:
#			${RM} -r ${OB_BUILD_DIR}
#
#		DL_DIR     ?= ${OB_ROOT_DIR}/downloads
#		SSTATE_DIR ?= ${OB_ROOT_DIR}/sstate-cache
#	EOF
#}
#
### create_openbar_root_xxx <directory>
#create_openbar_root_simple() {
#	create_file "${1}/${OB_ROOT_FILE}" <<-EOF
#		### DO NOT EDIT THIS FILE ###
#		export PROJECT_TYPE          := simple
#		export OB_DEFCONFIG_DIR := \${CURDIR}/${OB_CONFIGS_DIR}
#		export OB_CONTAINER_DIR := \${CURDIR}/${OB_CONFIGS_DIR}/container
#
#		include ${OB_OPENBAR_DIR}/core/main.mk
#		### DO NOT EDIT THIS FILE ###
#	EOF
#}
#
#create_openbar_root_initenv() {
#	create_file "${1}/${OB_ROOT_FILE}" <<-EOF
#		### DO NOT EDIT THIS FILE ###
#		export PROJECT_TYPE           := initenv
#		export OB_DEFCONFIG_DIR  := \${CURDIR}/${OB_CONFIGS_DIR}
#		export OB_CONTAINER_DIR  := \${CURDIR}/${OB_CONFIGS_DIR}/container
#		export OB_INITENV_SCRIPT := \${CURDIR}/${OB_INITENV_SCRIPT}
#
#		include ${OB_OPENBAR_DIR}/core/main.mk
#		### DO NOT EDIT THIS FILE ###
#	EOF
#}
#
#create_openbar_root_yocto() {
#	create_file "${1}/${OB_ROOT_FILE}" <<-EOF
#		### DO NOT EDIT THIS FILE ###
#		export PROJECT_TYPE           := yocto
#		export OB_DEFCONFIG_DIR  := \${CURDIR}/${OB_CONFIGS_DIR}
#		export OB_CONTAINER_DIR  := \${CURDIR}/${OB_CONFIGS_DIR}/container
#		export OB_INITENV_SCRIPT := \${CURDIR}/${OB_POKY_DIR}/oe-init-build-env
#
#		include ${OB_OPENBAR_DIR}/core/main.mk
#		### DO NOT EDIT THIS FILE ###
#	EOF
#}
#
### create_manifest_simple <directory>
#create_manifest_simple() {
#	CONFIG_TOPDIR=$(dirname "${OB_GIT_MAIN_PATH}")
#	ORIGIN_FETCH=$(realpath -m --relative-to="${CONFIG_TOPDIR:-.}" .)
#
#	cat <<EOF >"${1}/default.xml"
#<?xml version="1.0" encoding="UTF-8"?>
#<manifest>
#  <remote name="origin" fetch="${ORIGIN_FETCH}" />
#  <remote name="github" fetch="https://github.com" />
#
#  <default remote="origin" revision="main" sync-j="4" />
#
#  <project path="${OB_OPENBAR_DIR}" remote="github" revision="${OB_VERSION}" upstream="main" name="${OB_REPOSITORY_NWO}" />
#
#  <project path="${OB_CONFIGS_DIR}" name="${OB_GIT_MAIN_PATH}" >
#    <copyfile src="${OB_ROOT_FILE}" dest="Makefile" />
#  </project>
#</manifest>
#EOF
#}
#
### create_manifest_yocto <directory>
#create_manifest_yocto() {
#	CONFIG_TOPDIR=$(dirname "${OB_GIT_MAIN_PATH}")
#	ORIGIN_FETCH=$(realpath -m --relative-to="${CONFIG_TOPDIR:-.}" .)
#
#	cat <<EOF >"${1}/default.xml"
#<?xml version="1.0" encoding="UTF-8"?>
#<manifest>
#  <remote name="origin" fetch="${ORIGIN_FETCH}" />
#  <remote name="github" fetch="https://github.com" />
#
#  <default remote="origin" revision="main" sync-j="4" />
#
#  <project path="${OB_OPENBAR_DIR}" remote="github" revision="${OB_VERSION}" upstream="main" name="${OB_REPOSITORY_NWO}" />
#
#  <project path="${OB_CONFIGS_DIR}" name="${OB_GIT_MAIN_PATH}" >
#    <copyfile src="${OB_ROOT_FILE}" dest="Makefile" />
#  </project>
#
#  <project path="${OB_POKY_DIR}" remote="github" revision="master" name="yoctoproject/poky" />
#EOF
#
#	if [ "${OB_YOCTO_OE}" = yes ]; then
#		cat <<EOF >>"${1}/default.xml"
#  <project path="${OB_OE_DIR}" remote="github" revision="master" name="openembedded/meta-openembedded" />
#EOF
#	fi
#
#	cat <<EOF >>"${1}/default.xml"
#</manifest>
#EOF
#}
#
### create_gitignore_submodule <directory>
#create_gitignore_submodule() {
#	cat <<EOF >"${1}/.gitignore"
#/.config*
#EOF
#}

### create_project
#create_project() {
#	echo
#
#	echo "Creating git directory..."
#	mkdir -p "${OB_GIT_MAIN_PATH}" "${OB_GIT_MANIFEST_PATH}"
#
#	echo "Initializing git directory..."
#	for DIR in $(echo "${OB_GIT_MAIN_PATH}" "${OB_GIT_MANIFEST_PATH}" | tr " " "\n" | sort -u); do
#		git -C "${DIR}" init --quiet
#	done
#
#	if [ "${OB_GIT_TYPE}" = submodule ]; then
#		CONFIGS_DIR=${OB_GIT_MAIN_PATH}/${OB_CONFIGS_DIR}
#		ROOT_DIR=${OB_GIT_MAIN_PATH}
#
#		echo "Adding openbar submodule..."
#		git -C "${OB_GIT_MAIN_PATH}" submodule --quiet add "${OB_REPOSITORY_URL}" "${OB_OPENBAR_DIR}"
#		git -C "${OB_GIT_MAIN_PATH}/${OB_OPENBAR_DIR}" checkout --quiet "${OB_VERSION}"
#
#		if [ -n "${OB_POKY_DIR}" ]; then
#			echo "Adding poky submodule..."
#			git -C "${OB_GIT_MAIN_PATH}" submodule --quiet add "https://git.yoctoproject.org/poky" "${OB_POKY_DIR}"
#		fi
#
#		if [ -n "${OB_OE_DIR}" ]; then
#			echo "Adding meta-openembedded submodule..."
#			git -C "${OB_GIT_MAIN_PATH}" submodule --quiet add "https://git.openembedded.org/meta-openembedded" "${OB_OE_DIR}"
#		fi
#
#		create_gitignore_submodule "${ROOT_DIR}"
#
#	elif [ "${OB_GIT_TYPE}" = repo ]; then
#		CONFIGS_DIR=${OB_GIT_MAIN_PATH}
#		ROOT_DIR=${CONFIGS_DIR}
#
#		echo "Creating manifest..."
#		"create_manifest_${PROJECT_TYPE}" "${OB_GIT_MANIFEST_PATH}"
#	fi
#
#	echo "Creating dockerfile..."
#	"create_dockerfile_${PROJECT_TYPE}" "${CONFIGS_DIR}"
#
#	echo "Creating defconfig..."
#	"create_defconfig_${PROJECT_TYPE}" "${CONFIGS_DIR}"
#
#	echo "Creating openbar root file..."
#	"create_openbar_root_${PROJECT_TYPE}" "${ROOT_DIR}"
#
#	echo "Creating initial commit..."
#	for DIR in $(echo "${OB_GIT_MAIN_PATH}" "${OB_GIT_MANIFEST_PATH}" | tr " " "\n" | sort -u); do
#		git -C "${DIR}" add -A
#		git -C "${DIR}" commit --quiet -m "initial commit"
#		git -C "${DIR}" branch --quiet -M "${OB_GIT_BRANCH}"
#
#		if [ "${OB_GIT_REMOTE}" = yes ]; then
#			git -C "${DIR}" remote add origin "${OB_GIT_BASEURL}/${DIR}"
#		fi
#	done
#}

main() {
	# Ask the required configuration for the project

	PROJECT_NAME=$(ask_value "What is the name of your project?" | sanitize onlyprint noslash nospace preferedlower)

	PROJECT_TYPE=$(ask_select "What type of project is it?" "simple:initenv:yocto" "simple")

	GIT_TYPE=$(ask_select "How do you want to manage the git repositories?" "submodule:repo" "repo")

	if [ "${GIT_TYPE}" = repo ]; then
		GIT_MAIN_PATH_DEFAULT="${PROJECT_NAME}/configs"

		if ask_yesno "Do you want the repo manifest to be stored in a dedicated repository?" "yes"; then
			REPO_TYPE="split"
		fi
	else
		GIT_MAIN_PATH_DEFAULT="${PROJECT_NAME}"
	fi

	if [ "${PROJECT_TYPE}" = yocto ]; then
		OPENBAR_DIR_DEFAULT="platform/openbar"

		if ask_yesno "Do you need meta-openembedded?" "no"; then
			YOCTO_OE=yes
		fi
	else
		OPENBAR_DIR_DEFAULT="third-party/openbar"
	fi

	#	OB_GIT_MAIN_PATH=$(ask_value "What is the path of the main git repository?" "${OB_GIT_MAIN_PATH_DEFAULT}" |
	#		sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#
	#	if [ "${OB_REPO_TYPE}" = split ]; then
	#		OB_GIT_MANIFEST_PATH=$(ask_value "What is the path of the manifest git repository?" "${PROJECT_NAME}/manifest" |
	#			sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#	else
	#		OB_GIT_MANIFEST_PATH="${OB_GIT_MAIN_PATH}"
	#	fi
	#
	#	OB_CONFIGS_DIR=$(ask_value "What is the path of the configuration directory?" "configs" |
	#		sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#
	#	OB_OPENBAR_DIR=$(ask_value "What is the path of the openbar directory?" "${OB_OPENBAR_DIR_DEFAULT}" |
	#		sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#
	#	if [ "${PROJECT_TYPE}" = yocto ]; then
	#		OB_POKY_DIR=$(ask_value "What is the path of the poky directory?" "platform/poky" |
	#			sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#
	#		if [ "${OB_YOCTO_OE}" = yes ]; then
	#			OB_OE_DIR=$(ask_value "What is the path of the meta-openembedded directory?" "platform/meta-openembedded" |
	#				sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#		fi
	#	fi
	#
	#	if [ "${OB_GIT_TYPE}" = repo ]; then
	#		OB_ROOT_FILE=$(ask_value "What is the name of the openbar root file?" "openbar.mk" |
	#			sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#	else
	#		OB_ROOT_FILE="Makefile"
	#	fi
	#
	#	OB_DEFCONFIG_FILE=$(ask_value "What is the name of the default configuration file?" "${PROJECT_NAME}_defconfig" |
	#		sanitize onlyprint noslash nospace trailingdefconfig preferedlower)
	#
	#	OB_GIT_BRANCH=$(ask_value "What is the name of the git branch?" "main" |
	#		sanitize onlyprint noleadingslash notrailingslash nospace preferedlower)
	#
	#	if ask_yesno "Do you want to configure the git remote?" "no"; then
	#		OB_GIT_REMOTE=yes
	#
	#		OB_GIT_BASEURL=$(ask_value "What is the git base url?" "git@github.com:")
	#	fi
	#
	#	OB_OUTPUT_DIR=$(ask_value "What is the output directory?" "." |
	#		sanitize onlyprint notrailingslash)
	#
	#	# Generate the specified project
	#
	#	(
	#		cd "${TMP_DIR}" || exit 1
	#		create_project "${TMP_DIR}"
	#	)
	#
	#	mkdir -p "${OB_OUTPUT_DIR}"
	#	mv "${TMP_DIR}/"* "${OB_OUTPUT_DIR}"
}

# This script should be piped into `sh` and so the stdin will be lost.
# Reconnect it explicitly to /dev/tty.
(main) </dev/tty
