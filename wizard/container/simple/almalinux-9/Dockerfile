FROM	docker.io/almalinux:9-minimal

RUN	set -x \
	&& microdnf install --assumeyes \
		bash \
		gawk \
		make \
		util-linux \
	&& microdnf clean all
