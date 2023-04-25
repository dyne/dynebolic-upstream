ARCH ?= amd64
MODE ?= root
VARIANT ?= apt
# essential, minbase
FORMAT ?= dir

all: base linux-libre xorg lxqt

base:
	 mmdebstrap \
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
		--include='ca-certificates locales apt-transport-https curl' \
		--comp=main --arch=${ARCH} \
	daedalus ROOT http://deb.devuan.org/merged

linux-libre:
	@echo "Install linux-libre"
	@cp freesh-archive-keyring_1.1_all.deb ROOT/
	chroot ROOT dpkg -i /freesh-archive-keyring_1.1_all.deb
	chroot ROOT apt-get update
	chroot ROOT apt-get -q -y install linux-libre-6.1*

xorg:
	@echo "Install X11"
	chroot ROOT apt-get -q -y install xorg xinit xnest xserver-xorg-video-dummy
	@echo " install headless driver"
	@cp xorg-headless.conf ROOT/etc/X11/xorg.conf.d/10-headless.conf

lxqt:
	@echo "Install LXQT"
	chroot ROOT apt-get -q -y install lxqt

squash:
	@echo "Squash ROOT in compressed form"
	cd ROOT & tar c ./ | tar2sqfs -c zstd dynebolic.squash

clean:
	rm -rf ROOT

# > dynebolic-stage1.tar
# @ls -lh dynebolic-stage1.tar
# @echo "Squashing filesystem..."
# @rm -f dynebolic-stage1.squash
# cat dynebolic-stage1.tar | tar2sqfs -q -c zstd dynebolic-stage1.squash
# @ls -lh dynebolic-stage1.squash
# @rm -f dynebolic-stage1.tar

#		--hook-dir=/usr/share/mmdebstrap/hooks/no-merged-usr \

#		--include freesh-archive-keyring_1.1_all.deb \

