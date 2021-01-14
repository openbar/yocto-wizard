FROM	ubuntu:20.04

RUN	set -x \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt update \
	&& apt install --no-install-recommends -y \
		build-essential \
		ca-certificates \
		chrpath \
		cpio \
		diffstat \
		file \
		gawk \
		git \
		locales \
		make \
		python3 \
		python3-distutils \
		wget \
	&& rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 en_US.UTF-8

ENV	LANG en_US.utf8
