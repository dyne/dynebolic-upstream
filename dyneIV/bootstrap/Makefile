MODE ?= unshare
VARIANT ?= apt
# essential, minbase
FORMAT ?= tar

stage1:
	cat stage1-sources.list | mmdebstrap \
		--mode=${MODE} --variant=${VARIANT} --format=${FORMAT} \
		--aptopt='Apt::Install-Recommends "false"' \
		--aptopt='APT::Install-Suggests "false"' \
		--dpkgopt='path-exclude=/usr/share/doc/*' \
		--hook-dir=/usr/share/mmdebstrap/hooks/eatmydata \
		--hook-dir=/usr/share/mmdebstrap/hooks/file-mirror-automount \
		--comp=main --arch=amd64 \
	> dynebolic-stage1.tar
	@ls -lh dynebolic-stage1.tar
	@echo "Squashing filesystem..."
	@rm -f dynebolic-stage1.squash
	cat dynebolic-stage1.tar | tar2sqfs -q -c zstd dynebolic-stage1.squash
	@ls -lh dynebolic-stage1.squash
	@rm -f dynebolic-stage1.tar

#		--hook-dir=/usr/share/mmdebstrap/hooks/no-merged-usr \

#		--include freesh-archive-keyring_1.1_all.deb \

# --essential-hook='echo tzdata tzdata/Areas select Europe | chroot "$1" debconf-set-selections' \
# --essential-hook='echo tzdata tzdata/Zones/Europe select Amsterdam | chroot "$1" debconf-set-selections' \
