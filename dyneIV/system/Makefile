# Copyright (C) 2023-2024 Dyne.org Foundation
#
# Designed, written and maintained by Denis Roio <jaromil@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, , see <https://www.gnu.org/licenses/>.

# Use this makefile as root

SRC=$(shell dirname $(shell pwd))

include ${SRC}/config.mk

.SECONDEXPANSION:

all: need-suid apt-get-update build-root dyne-software squash-root squash-home squash-static

clean:
	rm -f ${SRC}/build/dyneIV-root-amd64.squashfs
	rm -f ${SRC}/build/dyneIV-home-amd64.squashfs
	rm -f ${SRC}/build/dyneIV-static-amd64.squashfs
	rm -f ${SRC}/build/dyneIV-devroot-amd64.squashfs

build-root:
	$(call install-packages,base-system-apt.txt)

dyne-software: ##
	$(call chroot-script,dyne-software.sh)

squash-root: EXCLUDE_FOR := release
squash-root: target := ${SRC}/build/dyneIV-root-${ARCH}.squashfs
squash-root: need-suid prepare-excludes
	@echo "--\n-- Squash build: root to ${SRC}/build/dyneIV-root-${ARCH}.squashfs"
	@mkdir -p ${SRC}/build
	@$(if $(wildcard ${ROOT}),,$(error Folder not found: ${ROOT}))
	@$(if $(wildcard ${ROOT}/proc/meminfo),umount ${ROOT}/proc)
	@$(if $(wildcard ${ROOT}/dev/mem),umount ${ROOT}/dev)
	@$(call chroot-script,${SRC}/fixperms.sh)
	@tar -c --exclude-from=/tmp/dyneIV-excludes ${ROOT} \
		| pv -p -s `du -sb ${ROOT} | awk '{print $$1}'` \
		| tar2sqfs -r ${ROOT} -f -q ${SQFSCONF} ${target}

root: need-suid apt-get-update build-root dyne-software squash-root

devroot: need-suid apt-get-update build-root dyne-software squash-devroot

home: squash-home

squash-home: need-suid
	@echo "--\n-- Squash build: home to ${SRC}/build/dyneIV-home-${ARCH}.squashfs"
	@mkdir -p ${SRC}/build
	@chown -R 1000:1000 ${SRC}/static/home/dyne
	@chown -R root:root ${SRC}/static/root
	@tar -c --exclude ${SRC}/static/usr --exclude ${SRC}/static/etc \
		${SRC}/static \
		| tar2sqfs -r ${SRC}/static -f -q ${SQFSCONF} \
			"${SRC}/build/dyneIV-home-${ARCH}.squashfs"
	@echo "--\n-- Done: ${SRC}/build/dyneIV-home-${ARCH}.squashfs\n--"

static: squash-static

squash-static: need-suid
	@echo "--\n-- Squash build: static to ${SRC}/build/dyneIV-static-${ARCH}.squashfs"
	@mkdir -p ${SRC}/build
	@tar -c --exclude ${SRC}/static/home --exclude ${SRC}/static/root  \
			--owner 0:0 ${SRC}/static \
		| tar2sqfs -r ${SRC}/static -f -q ${SQFSCONF} \
			"${SRC}/build/dyneIV-static-${ARCH}.squashfs"
	@echo "--\n-- Done: ${SRC}/build/dyneIV-static-${ARCH}.squashfs\n--"

# cli-utils: ##
# 	$(call install-packages,cli-utils.txt)

# desktop-kde: ##
# 	$(call install-packages,desktop-kde.txt)

# creative-multimedia: ##
# 	$(call install-packages,creative-multimedia.txt)

# fun-games: ##
# 	$(call install-packages,fun-games.txt)

# cli-emacs: ##
# 	$(call install-packages,cli-emacs.txt)
