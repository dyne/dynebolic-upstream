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

.SECONDEXPANSION:
all: init-stage3 install-all-packages shrink pack-stage3

include ${SRC}/config.mk

init-stage3: need-suid
	$(if $(wildcard ${SRC}/${STAGE3}),$(error Cannot overwrite stage3))
	$(info Open third stage bootstrap)
	@rm -rf ROOT
	@mkdir -p ROOT && cd ROOT && sudo tar xf ${SRC}/${STAGE2}
	@chroot ROOT apt-get update -q -y

pack-stage3: size := $(if $(wildcard ${ROOT}),$(shell du -sb ${ROOT} | awk '{print $$1}'),0)
pack-stage3: need-suid
	$(if $(wildcard ${SRC}/${STAGE3}),$(error Cannot overwrite stage3))
	@cd ${ROOT} && tar cf - * | pv -s ${size} | gzip - > ${SRC}/${STAGE3}

install-all-packages: need-suid
	$(call install-packages,cli-utils)
	$(call install-packages,desktop-kde)

# $(call install-packages,desktop-mate)

apply-all-patches: need-suid
	$(call apply-patch,/etc/init.d/xdm,etc-initd-xdm.patch)

# installs += install-xorg
# install-xorg: need-suid
# 	$(call chroot-script,install-xorg.sh)

# installs += install-audio
# install-audio: need-suid
# 	$(call chroot-script,install-audio.sh)

clean: need-suid
	$(info Delete packages.)
	@rm -f ${SRC}/${STAGE3}
