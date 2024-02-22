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

help:
	@echo "✨ Packages available for install on your Dyne:IV system"
	@awk 'BEGIN {FS = ":.*##"; printf "🛟 Usage: make \033[36m<target>\033[0m\n👇🏽 List of targets:\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf " \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5)} ' Makefile


.SECONDEXPANSION:

include ${SRC}/config.mk

all: need-suid apt-get-update cli-utils desktop-kde creative-multimedia fun-games dyne-software

cli-utils: ##
	$(call install-packages,cli-utils.txt)

desktop-kde: ##
	$(call install-packages,desktop-kde.txt)

creative-multimedia: ##
	$(call install-packages,creative-multimedia.txt)

fun-games: ##
	$(call install-packages,fun-games.txt)

dyne-software: ##
	$(call chroot-script,dyne-software.sh)

cli-emacs: ##
	$(call install-packages,cli-emacs.txt)
