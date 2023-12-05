#!/bin/sh

apt-get -q -y install mount live-boot zstd direnv \
		openrc sysvinit-core psmisc e2fsprogs orphan-sysvinit-scripts
update-initramfs -k all -c
