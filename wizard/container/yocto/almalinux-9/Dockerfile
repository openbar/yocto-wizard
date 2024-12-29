FROM	docker.io/almalinux:9-minimal

ENV	LANG en_US.utf8

RUN	set -x \
	&& microdnf install --assumeyes \
		bash \
		bzip2 \
		ca-certificates \
		chrpath \
		cpio \
		diffstat \
		diffutils \
		file \
		gawk \
		gcc \
		gcc-c++ \
		git \
		glibc-locale-source \
		hostname \
		lz4 \
		make \
		patch \
		perl \
		python3 \
		rpcgen \
		tar \
		wget \
		which \
		xz \
		zstd \
	&& microdnf clean all \
	&& localedef -c -i en_US -f UTF-8 en_US.UTF-8
