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
all: stage1 stage2 pack-stage2

include ${SRC}/config.mk

stage1: MODE ?= unshare
stage1: VARIANT ?= apt
stage1: FORMAT ?= tar
stage1: APT_PROXY_OPT := $(shell APT_PROXY_OVERRIDE="${APT_PROXY_OVERRIDE}" ${SRC}/bootstrap/generate-proxy-opt.sh)
stage1: need-suid
	@if ! [ -r ${SRC}/${STAGE0} ]; then \
	echo "Bootstrap a new stage0: ${STAGE0}"; \
	UNSHARE_USERS=1 mmdebstrap \
		--mode=${MODE} --variant=${VARIANT} --format=${FORMAT} \
		--aptopt='Apt::Install-Recommends "false"' \
		--aptopt='APT::Install-Suggests "false"' \
		--aptopt='Acquire::Retries "5"' ${APT_PROXY_OPT} \
		--dpkgopt='path-exclude=/usr/share/doc/*' \
		--essential-hook='echo tzdata tzdata/Areas select Europe | chroot "$$1" debconf-set-selections' \
		--essential-hook='echo tzdata tzdata/Zones/Europe select Amsterdam | chroot "$$1" debconf-set-selections' \
		--hook-dir=/usr/share/mmdebstrap/hooks/eatmydata \
		--hook-dir=/usr/share/mmdebstrap/hooks/file-mirror-automount \
		--include='devuan-keyring' \
		--include='ca-certificates locales apt-transport-https curl apt-utils netcat-openbsd' \
		--comp=main --arch=${ARCH} \
	daedalus ${SRC}/${STAGE0} http://packages.devuan.org/merged; \
	else echo "Stage0 found: ${STAGE0}"; fi
	@if ! [ -r ${SRC}/${STAGE1} ]; then \
	  if ! [ -r ${ROOT} ]; then \
	    mkdir -p ${ROOT} ;\
	    tar -C ${ROOT} -xf ${SRC}/${STAGE0} ;\
	  fi ;\
	  echo "Bootstrap a new stage1: ${STAGE1}"; \
	  cp freesh-archive-keyring_1.1_all.deb ${ROOT}/usr/src/ ;\
	  cp install-kernel-libre.sh ${ROOT}/free.sh ;\
	  mount -o bind /proc ${ROOT}/proc ;\
	  mount -o bind /dev/pts ${ROOT}/dev/pts ;\
	  mount -o bind /dev/null ${ROOT}/dev/null ;\
	  chroot ${ROOT} bash -e /free.sh ;\
	  umount ${ROOT}/proc ;\
	  umount ${ROOT}/dev/pts ;\
	  umount ${ROOT}/dev/null ;\
	  rm -f ${ROOT}/etc/apt/sources.list.d/freesh.sources ;\
	  du -hs ${ROOT} && cd ${ROOT} && tar -c . | xz -v -z -9 -T0 --memlimit-compress=70% > ${SRC}/${STAGE1} ;\
	else echo "Stage1 found: ${STAGE1}"; fi

root:
	@if ! [ -r ${ROOT} ]; then \
        mkdir -p ${ROOT} ;\
        tar -C ${ROOT} -xf ${SRC}/${STAGE1} ;\
    fi

stage2: root
	$(info Open first stage bootstrap)
	$(call chroot-script,install-apt-conf.sh)
	$(call upgrade-packages)
	$(call install-packages,base-packages)
	$(call chroot-script,install-users.sh)
	$(call install-packages,live-boot.txt)
	$(call chroot-script,install-live-boot.sh)
	$(call chroot-script,install-locale.sh)


pack-stage2: need-suid
	$(if $(wildcard ${ROOT}),,$(error ROOT not found.))
	$(info Packing Stage2)
	@du -hs ${ROOT} && cd ${ROOT} && tar -c . | xz -v -z -9 -T0 --memlimit-compress=70% > ${SRC}/${STAGE2}

#$(if $(wildcard ${SRC}/${STAGE2}),$(error Cannot overwrite stage2))

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
