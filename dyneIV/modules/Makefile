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

.SECONDEXPANSION:
all: module

include ${SRC}/config.mk

prepare-modfiles:
	$(if $(wildcard ${MOD}-files.txt),,$(error Module not found: ${MOD}-files.txt))
	@rm -f /tmp/dyneIV-${MOD}-files
	@awk '/^#/{next} /^$$/{next} /^\*/{print $$0; next} /^\//{printf("'"${ROOT}"'%s\n",$$1)}' ${MOD}-files.txt > /tmp/dyneIV-${MOD}-files

modsquash: MOD ?= local
modsquash: target := dyneIV-module-${MOD}.squash
modsquash: need-suid static-overlay prepare-modfiles
	$(if $(wildcard ${MOD}-files.txt),,$(error Module not found: ${MOD}-files.txt))
	$(info Squashing module: ${MOD}-files.txt)
	tar -c --files-from=/tmp/dyneIV-${MOD}-files \
		| tar2sqfs -r ${ROOT} -f -q -c xz -X level=9 ${SRC}/filesystem.${MOD}.squashfs
