# Copyright (C) 2024 Dyne.org Foundation
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

SRC=$(shell dirname $(shell pwd))

.PHONY: kde multimedia games

all: kde multimedia games

include ${SRC}/config.mk


# use adding to tar  --exclude-from=/tmp/dyneIV-excludes
module-excludes:
	$(if $(wildcard ${SRC}/exclude-for-${EXCLUDE_FOR}.txt),,$(error Exclude file not found: ${EXCLUDE_FOR}))
	$(info Filesystem exclusion mask target: ${EXCLUDE_FOR})
	@rm -f /tmp/dyneIV-mod-${MOD}-excludes
	@awk '/^#/{next} /^$$/{next} /^\*/{print $$0; next} /^\//{printf("'"${MOD}-mnt"'%s\n",$$1)}' ${SRC}/exclude-for-${EXCLUDE_FOR}.txt | tee /tmp/dyneIV-mod-${MOD}-excludes
	$(info /tmp/dyneIV-mod-${MOD}-excludes)

apt-module:
	$(if $(wildcard ${MOD}-apt.txt),,$(error Package file not found: ${MOD}-apt.txt))
	mkdir -p ${MOD}-mnt ${MOD}-work ${MOD}-buildroot
	fuse-overlayfs -o lowerdir=${ROOT} -o upperdir=${MOD}-mnt \
	 -o workdir=${MOD}-work  ${MOD}-buildroot
	@echo "-- Install APT packaged for module: ${MOD}\n--"
	@echo "DEBIAN_FRONTEND=noninteractive apt-get -q -y update" > ${MOD}-buildroot/install.sh
	@echo "DEBIAN_FRONTEND=noninteractive apt-get -q -y upgrade" >> ${MOD}-buildroot/install.sh
	@echo "DEBIAN_FRONTEND=noninteractive apt-get install -q -y $(shell awk '/^$$/{next} !/^#/{printf("%s ",$$1)}' ${MOD}-apt.txt)" >> ${MOD}-buildroot/install.sh
	mount -o bind /proc ${MOD}-buildroot/proc
	mount -o bind /dev/pts  ${MOD}-buildroot/dev/pts
	mount -o bind /dev/null  ${MOD}-buildroot/dev/null
	-chroot ${MOD}-buildroot /bin/bash -e /install.sh
	-umount ${MOD}-buildroot/proc
	-umount ${MOD}-buildroot/dev/pts
	-umount ${MOD}-buildroot/dev/null
	rm -f  ${MOD}-buildroot/install.sh
	umount ${MOD}-buildroot
	@echo "-- Done ${MOD} apt\n--"

#	rm -rf ${MOD}-work ${MOD}-buildroot

script-module:
	$(if $(wildcard ${MOD}-script.sh),,$(error Package file not found: ${MOD}-script.sh))
	mkdir -p ${MOD}-mnt ${MOD}-work ${MOD}-buildroot
	fuse-overlayfs -o lowerdir=${ROOT} -o upperdir=${MOD}-mnt \
	 -o workdir=${MOD}-work  ${MOD}-buildroot
	cp ${MOD}-script.sh ${MOD}-buildroot/script.sh
	mount -o bind /proc ${MOD}-buildroot/proc
	mount -o bind /dev/pts  ${MOD}-buildroot/dev/pts
	mount -o bind /dev/null  ${MOD}-buildroot/dev/null
	-chroot ${MOD}-buildroot /bin/bash -e /script.sh
	-umount ${MOD}-buildroot/proc
	-umount ${MOD}-buildroot/dev/pts
	-umount ${MOD}-buildroot/dev/null
	rm -f  ${MOD}-buildroot/script.sh
	umount ${MOD}-buildroot
	@echo "-- Done ${MOD} script\n--"

#	rm -rf ${MOD}-work ${MOD}-buildroot

# $1: target
# $2: folder
squash-module:
	$(if $(wildcard ${MOD}-mnt),,$(error Folder not found: ${MOD}-mnt))
	rm -f ${SRC}/build/dyneIV-mod-${MOD}-${ARCH}.squashfs
	@echo "--\n-- Squash build: ${MOD} to ${SRC}/build/dyneIV-mod-${MOD}-${ARCH}.squashfs"
	@mkdir -p ${SRC}/build
	@tar -c --exclude-from=/tmp/dyneIV-mod-${MOD}-excludes ${MOD}-mnt \
		| pv -p -s `du -sb ${MOD}-mnt | awk '{print $$1}'` \
		| tar2sqfs -r ${MOD}-mnt -f -q ${SQFSCONF} \
			"${SRC}/build/dyneIV-mod-${MOD}-${ARCH}.squashfs"
	@echo "--\n-- Done: ${SRC}/build/dyneIV-mod-${MOD}-${ARCH}.squashfs\n--"

#	$(if $(wildcard ${SRC}/build/dyneIV-mod-${MOD}-${ARCH}.squashfs),$(error Cannot overwrite: ${SRC}/build/dyneIV-mod-${MOD}-${ARCH}.squashfs))

kde: MOD := kde
kde: EXCLUDE_FOR := release
kde: apt-module script-module module-excludes squash-module

multimedia: MOD := multimedia
multimedia: EXCLUDE_FOR := release
multimedia: apt-module script-module module-excludes squash-module

# script-module in multimedia includes libreoffice

games: MOD := games
games: EXCLUDE_FOR := release
games: apt-module module-excludes squash-module

kde-squash: MOD := kde
kde-squash: EXCLUDE_FOR := release
kde-squash: module-excludes squash-module

games-squash: MOD := games
games-squash: EXCLUDE_FOR := release
games-squash: module-excludes squash-module

clean:
	rm -rf *-mnt
	rm -f ${SRC}/build/dyneIV-mod-*

prepare-modfiles:
	$(if $(wildcard ${MOD}-files.txt),,$(error Module not found: ${MOD}-files.txt))
	@rm -f /tmp/dyneIV-${MOD}-files
	@awk '/^#/{next} /^$$/{next} /^\*/{print $$0; next} /^\//{printf("'"${ROOT}"'%s\n",$$1)}' ${MOD}-files.txt > /tmp/dyneIV-${MOD}-files

fixperms: need-suid
	$(if $(wildcard ${MOD}-mnt),,$(error Build mount not found: ${MOD}-mnt))
	$(call chroot-script-into,${SRC}/fixperms.sh,${MOD}-mnt)
