FROM	docker.io/fedora:40

ENV	LANG en_US.utf8

RUN	set -x \
	&& dnf install --assumeyes \
		bash \
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
		perl-File-Compare \
		perl-File-Copy \
		perl-FindBin \
		perl-Thread-Queue \
		python3 \
		rpcgen \
		wget2-wget \
		which \
	&& dnf clean all \
	&& localedef -c -i en_US -f UTF-8 en_US.UTF-8
