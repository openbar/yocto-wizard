FROM	docker.io/debian:12-slim

ENV	LANG en_US.utf8

RUN	set -x \
	&& apt update \
	&& apt install --yes \
		bash \
		bzip2 \
		chrpath \
		cpio \
		diffstat \
		file \
		g++ \
		gawk \
		gcc \
		git \
		locales \
		lz4 \
		make \
		python3 \
		wget \
		xz-utils \
		zstd \
	&& rm -rf /var/lib/apt/lists/* \
	&& localedef -c -i en_US -f UTF-8 en_US.UTF-8
