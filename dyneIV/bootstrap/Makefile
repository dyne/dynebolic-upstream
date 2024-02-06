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

# [optional] sudo chroot ROOT (r/w)
# [optional] squashfuse dynebolic.squash /mnt (r/o)
# [optional] sudo chroot /mnt (r/o)
# [optional] umount /mnt

SRC=$(shell dirname $(shell pwd))


# second expansion is needed to get the value of
# $(installs) after the whole file was preprocessed
.SECONDEXPANSION:
all: stage1 stage2 shrink pack-stage2

# shrink close-stage2

include ${SRC}/config.mk

stage1: MODE ?= unshare
stage1: VARIANT ?= apt
stage1: FORMAT ?= tar
stage1: need-suid
	@if ! [ -r ${SRC}/${STAGE1} ]; then \
	echo "Bootstrap a new stage1: ${STAGE1}"; \
	UNSHARE_USERS=1 mmdebstrap \
		--mode=${MODE} --variant=${VARIANT} --format=${FORMAT} \
		--aptopt='Apt::Install-Recommends "false"' \
		--aptopt='APT::Install-Suggests "false"' \
		--aptopt='Acquire::Retries "5"' \
		--dpkgopt='path-exclude=/usr/share/doc/*' \
		--essential-hook='echo tzdata tzdata/Areas select Europe | chroot "$$1" debconf-set-selections' \
		--essential-hook='echo tzdata tzdata/Zones/Europe select Amsterdam | chroot "$$1" debconf-set-selections' \
		--hook-dir=/usr/share/mmdebstrap/hooks/eatmydata \
		--hook-dir=/usr/share/mmdebstrap/hooks/file-mirror-automount \
		--include='devuan-keyring' \
		--include='ca-certificates locales apt-transport-https curl apt-utils netcat-openbsd' \
		--comp=main --arch=${ARCH} \
	daedalus ${SRC}/${STAGE1} http://deb.devuan.org/merged; \
	fi

stage2: need-suid
	$(if $(wildcard ${SRC}/${STAGE2}),$(error Cannot overwrite stage2))
	@rm -rf ${ROOT}
	$(info Open first stage bootstrap)
	@mkdir -p ${ROOT}
	@tar -C ${ROOT} -xf ${SRC}/${STAGE1}
	@cp freesh-archive-keyring_1.1_all.deb ${ROOT}/usr/src/
	$(call chroot-script,install-kernel-libre.sh)
	@chroot ${ROOT} apt-get update -q -y
	$(call install-packages,base-packages)
	$(call chroot-script,install-users.sh)
	$(call chroot-script,install-live-boot.sh)
	$(call chroot-script,install-locale.sh)

locales:
	$(call chroot-script,install-locale.sh)

pack-stage2: need-suid prepare-excludes
	$(if $(wildcard ${ROOT}),,$(error ROOT not found.))
	$(if $(wildcard ${SRC}/${STAGE2}),$(error Cannot overwrite stage2))
	$(info Packing Stage2)
	@du -hs ${ROOT} && cd ${ROOT} && tar -c --exclude-from=/tmp/dyneIV-excludes . | xz -v -z -9 -T0 > ${SRC}/${STAGE2}

# setup a local apt-proxy cache
apt-proxy: need-suid
	@echo 'Acquire::http::ProxyAutoDetect "/etc/apt/detect-http-proxy.sh";'\
		> ${ROOT}/etc/apt/apt.conf.d/30detectproxy
	@cp detect-http-proxy.sh ${ROOT}/etc/apt/ && chmod +x detect-http-proxy.sh
	@chroot ${ROOT} apt-get update -q -y
	@echo "--"
	@echo "-- Add this line to your apt-cache-ng conf:"
	@echo "-- Remap-devuan: deb.devuan.org packages.devuan.org /merged; http://packages.devuan.org/merged/"
	@echo "--\n"
