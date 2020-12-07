FROM	ubuntu:20.04

RUN	set -x \
	&& export DEBIAN_FRONTEND=noninteractive \
	&& apt update \
	&& apt install --no-install-recommends -y \
		make \
	&& rm -rf /var/lib/apt/lists/*
