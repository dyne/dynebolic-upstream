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


# # $1: target
# # $2: folder
# define squash-build
# 	$(if $(wildcard ${2}),,$(error Folder not found: ${2}))
# 	$(if $(wildcard ${SRC}/build/dyneIV-${1}-${ARCH}.squashfs),$(error Cannot overwrite: ${SRC}/build/dyneIV-${1}-${ARCH}.squashfs))
# 	@echo "--\n-- Squash build: ${2} to ${SRC}/build/dyneIV-${1}-${ARCH}.squashfs"
# 	@mkdir -p ${SRC}/build
# 	@tar -c ${2} \
# 		| pv -p -s `du -sb ${2} | awk '{print $$1}'` \
# 		| tar2sqfs -r ${2} -f -q -c xz \
# 			"${SRC}/build/dyneIV-${1}-${ARCH}.squashfs"
# 	@echo "--\n-- Done: ${SRC}/build/dyneIV-${1}-${ARCH}.squashfs\n--"
# endef

include ${SRC}/config.mk

.SECONDEXPANSION:


all: need-suid apt-get-update build-root squash-root squash-home squash-static

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
	@$(if $(wildcard ${target}),$(error Cannot overwrite: ${target}))
	@$(if $(wildcard ${ROOT}/proc/meminfo),umount ${ROOT}/proc)
	@$(if $(wildcard ${ROOT}/dev/mem),umount ${ROOT}/dev)
	tar -c --exclude-from=/tmp/dyneIV-excludes ${ROOT} \
		| pv -p -s `du -sb ${ROOT} | awk '{print $$1}'` \
		| tar2sqfs -r ${ROOT} -f -q ${SQFSCONF} ${target}

squash-home: folder := home
squash-home: need-suid
	@echo "--\n-- Squash build: home to ${SRC}/build/dyneIV-home-${ARCH}.squashfs"
	@mkdir -p ${SRC}/build
	@tar -c --exclude ${SRC}/static/usr --exclude ${SRC}/static/etc \
			--owner 1000:1000 ${SRC}/static \
		| tar2sqfs -r ${SRC}/static -f -q ${SQFSCONF} \
			"${SRC}/build/dyneIV-home-${ARCH}.squashfs"
	@echo "--\n-- Done: ${SRC}/build/dyneIV-home-${ARCH}.squashfs\n--"

squash-static: need-suid
	@echo "--\n-- Squash build: static to ${SRC}/build/dyneIV-static-${ARCH}.squashfs"
	@mkdir -p ${SRC}/build
	@tar -c --exclude ${SRC}/static/home \
			--owner 1:1 ${SRC}/static \
		| tar2sqfs -r ${SRC}/static -f -q ${SQFSCONF} \
			"${SRC}/build/dyneIV-static-${ARCH}.squashfs"
	@echo "--\n-- Done: ${SRC}/build/dyneIV-static-${ARCH}.squashfs\n--"

cli-utils: ##
	$(call install-packages,cli-utils.txt)

desktop-kde: ##
	$(call install-packages,desktop-kde.txt)

creative-multimedia: ##
	$(call install-packages,creative-multimedia.txt)

fun-games: ##
	$(call install-packages,fun-games.txt)

cli-emacs: ##
	$(call install-packages,cli-emacs.txt)
