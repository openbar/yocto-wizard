FROM	docker.io/opensuse/leap:15.6

RUN	set -x \
	&& zypper --non-interactive install \
		bash \
		gawk \
		make \
	&& zypper --non-interactive clean --all
