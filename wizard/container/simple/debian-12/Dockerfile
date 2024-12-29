FROM	docker.io/debian:12-slim

RUN	set -x \
	&& apt update \
	&& apt install --yes \
		bash \
		gawk \
		make \
	&& rm -rf /var/lib/apt/lists/*
