FROM	docker.io/rockylinux:9-minimal

RUN	set -x \
	&& microdnf install --assumeyes \
		bash \
		gawk \
		make \
	&& microdnf clean all
