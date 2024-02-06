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
all: install-all-packages

include ${SRC}/config.mk

install-all-packages:
install-all-packages: need-suid
	$(call install-packages,cli-utils)
	$(call chroot-script,install-guix.sh)
	$(call install-packages,desktop-kde)
	$(call install-packages,creative-multimedia)
	$(call install-packages,fun-games)

# apply-all-patches: need-suid
# 	$(call apply-patch,/etc/init.d/xdm,etc-initd-xdm.patch)


#  | xz -v -z -9 -T0 > ${SRC}/${STAGE3}
