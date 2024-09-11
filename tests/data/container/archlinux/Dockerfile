FROM	docker.io/archlinux

RUN	set -x \
	&& pacman --sync --noconfirm --refresh \
	&& pacman --sync --noconfirm bash gawk make \
	&& find /var/cache/pacman/pkg -mindepth 1 -delete
