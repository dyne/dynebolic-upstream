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
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, see <https://www.gnu.org/licenses/>.

SRC=$(shell dirname $(shell pwd))

# second expansion is needed to get the value of
# $(installs) after the whole file was preprocessed
.SECONDEXPANSION:
all: stage1 stage2 pack-stage2

include ${SRC}/config.mk

# URLs for the kernel packages
URL1=https://files.dyne.org/dynebolic/development/kernel/linux-image-6.13.3-gnu_6.13.3-gnu-3_amd64.deb
URL2=https://files.dyne.org/dynebolic/development/kernel/linux-headers-6.13.3-gnu_6.13.3-gnu-3_amd64.deb
URL3=https://files.dyne.org/dynebolic/development/kernel/linux-libc-dev_6.13.3-gnu-3_amd64.deb

# Download kernel packages
download-kernel:
	@echo "Starting download of kernel packages..."
	@mkdir -p kernel
	@for url in "${URL1}" "${URL2}" "${URL3}"; do \
		echo "Downloading $$url to kernel/ directory..."; \
		if ! curl -f -o "kernel/$$(basename $$url)" "$$url"; then \
			echo "Warning: Failed to download $$url"; \
			exit 1; \
		fi; \
	done
	@echo "All kernel packages downloaded successfully to kernel/ directory."

# added variables for customizations
# packages needed to be installed for and in the stage 1
# the options for apt during stage 1
# the hooks needed for the the stage 1
STAGE1_PACKAGES ?= devuan-keyring ca-certificates locales apt-transport-https curl apt-utils netcat-openbsd dialog
STAGE1_APT_OPTS ?= --aptopt='Apt::Install-Recommends "false"' --aptopt='APT::Install-Suggests "false"' --aptopt='Acquire::Retries "5"'
STAGE1_HOOKS ?= --hook-dir=/usr/share/mmdebstrap/hooks/eatmydata --hook-dir=/usr/share/mmdebstrap/hooks/file-mirror-automount

# Ensure download-kernel runs before stage1
stage1: download-kernel
stage1: MODE ?= unshare
stage1: VARIANT ?= apt
stage1: FORMAT ?= tar
stage1: APT_PROXY_OPT := $(shell APT_PROXY_OVERRIDE="${APT_PROXY_OVERRIDE}" ${SRC}/bootstrap/generate-proxy-opt.sh)
stage1: need-suid
	@if ! [ -r ${SRC}/${STAGE0} ]; then \
		echo "Bootstrap a new stage0: ${STAGE0}"; \
		UNSHARE_USERS=1 PAGER=cat mmdebstrap \
			--mode=${MODE} --variant=${VARIANT} --format=${FORMAT} \
			${STAGE1_APT_OPTS} ${APT_PROXY_OPT} \
			--dpkgopt='path-exclude=/usr/share/doc/*' \
			--essential-hook='echo tzdata tzdata/Areas select Europe | chroot "$$1" debconf-set-selections' \
			--essential-hook='echo tzdata tzdata/Zones/Europe select Amsterdam | chroot "$$1" debconf-set-selections' \
			${STAGE1_HOOKS} \
			--include='${STAGE1_PACKAGES}' \
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
		cp kernel/*.deb ${ROOT}/usr/src/ ;\
		cp install-kernel-libre.sh ${ROOT}/free.sh ;\
		mount -o bind /proc ${ROOT}/proc ;\
		mount -o bind /dev/pts ${ROOT}/dev/pts ;\
		mount -o bind /dev/null ${ROOT}/dev/null ;\
		chroot ${ROOT} bash -e /free.sh ;\
		umount ${ROOT}/proc ;\
		umount ${ROOT}/dev/pts ;\
		umount ${ROOT}/dev/null ;\
		rm -f ${ROOT}/etc/apt/sources.list.d/freesh.sources ;\
		du -hs ${ROOT} >&2 && cd ${ROOT} && tar -c . | xz -v -z -9 -T0 --memlimit-compress=70% > ${SRC}/${STAGE1} ;\
	else echo "Stage1 found: ${STAGE1}"; fi

# scripts to be run in and inside stage 2
# lists of packages for stage 2
STAGE2_SCRIPTS ?= install-apt-conf.sh install-users.sh install-live-boot.sh install-locale.sh
STAGE2_PACKAGES ?= base-packages live-boot.txt

stage2:
	$(info Open first stage bootstrap)
	$(foreach script,${STAGE2_SCRIPTS},$(call chroot-script,${script}))
	$(call upgrade-packages)
	$(foreach package,${STAGE2_PACKAGES},$(call install-packages,${package}))

pack-stage2: need-suid
	$(if $(wildcard ${ROOT}),,$(error ROOT not found.))
	$(if $(wildcard ${SRC}/${STAGE2}),$(error Cannot overwrite stage2))
	$(info Packing Stage2)
	# use - to ignore errors
	@-du -hs ${ROOT} && cd ${ROOT} && tar -c . | xz -v -z -9 -T0 --memlimit-compress=70% > ${SRC}/${STAGE2}

# setup a local apt-proxy cache
# APT_PROXY_SCRIPT ?= detect-http-proxy.sh
APT_PROXY_CONF ?= 30detectproxy

apt-proxy: need-suid
	@echo 'Acquire::http::ProxyAutoDetect "/etc/apt/${APT_PROXY_SCRIPT}";'\
		> ${ROOT}/etc/apt/apt.conf.d/${APT_PROXY_CONF}
	@cp ${APT_PROXY_SCRIPT} ${ROOT}/etc/apt/ && chmod +x ${ROOT}/etc/apt/${APT_PROXY_SCRIPT}
	@chroot ${ROOT} apt-get update -q -y
	@echo "--"
	@echo "-- Add this line to your apt-cache-ng conf:"
	@echo "-- Remap-devuan: deb.devuan.org packages.devuan.org /merged; http://packages.devuan.org/merged/"
	@echo "--\n"
