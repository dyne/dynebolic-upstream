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

#.SECONDEXPANSION:

all: EXCLUDE_FOR := release
all: target := ${SRC}/build/dyneIV-root-${ARCH}.squashfs
all: prepare-excludes 
	$(call upgrade-packages)
	$(call install-packages,base-system-apt.txt)
	$(call chroot-script,dyne-software.sh)
	$(call chroot-script,install-audio.sh)
	$(info Squash build: root to ${SRC}/build/dyneIV-root-${ARCH}.squashfs)
	$(call chroot-script,${SRC}/fixperms.sh)
	@mkdir -p ${SRC}/build
	@tar -c --exclude-from=/tmp/dyneIV-excludes ${ROOT} \
		| pv -p -s `du -sb ${ROOT} | awk '{print $$1}'` \
		| tar2sqfs -r ${ROOT} -f -q ${SQFSCONF} ${target}

clean:
	rm -f ${SRC}/build/dyneIV-root-amd64.squashfs

# use adding to tar  --exclude-from=/tmp/dyneIV-excludes
prepare-excludes:
	$(if $(wildcard ${SRC}/exclude-for-${EXCLUDE_FOR}.txt),,$(error Exclude file not found: ${EXCLUDE_FOR}))
	$(info Filesystem exclusion mask target: ${EXCLUDE_FOR})
	@rm -f /tmp/dyneIV-excludes
	@awk '/^#/{next} /^$$/{next} /^\*/{print $$0; next} /^\//{printf("'"${ROOT}"'%s\n",$$1)}' \
		${SRC}/exclude-for-${EXCLUDE_FOR}.txt > /tmp/dyneIV-excludes

