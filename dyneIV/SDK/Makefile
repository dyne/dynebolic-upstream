
all:
	@echo "make download (only once from sdk.dyne.org dynebolic live builds)"
	@echo "make unpack (decompresses the cpio in ./mnt for chroot)"
	@echo "make install (install all packages from install-scripts)"

STAGE3 ?= bootstrap-devuan-amd64-stage3.cpio.gz
STAGE4 ?= bootstrap-devuan-amd64-stage4.cpio.gz

# uses live-sdk to build stages
bootstrap:
	./build.sh

# download stages from sdk.dyne.org
download:
ifneq (,$(wildcard live-sdk))
	git clone --recursive --depth 1 https://git.devuan.org/devuan-sdk/live-sdk
endif
	@echo "Download stage3 from sdk.dyne.org"
	mkdir -p live-sdk/tmp && cd live-sdk/tmp && \
	wget -c https://sdk.dyne.org:4443/job/dynebolic-live-base/lastSuccessfulBuild/artifact/tmp/${STAGE3}
	@echo "Download stage4 from sdk.dyne.org"
	mkdir -p live-sdk/tmp && cd live-sdk/tmp && \
	wget -c https://sdk.dyne.org:4443/job/dynebolic-live-base/lastSuccessfulBuild/artifact/tmp/${STAGE4}

unpack:
ifneq (,$(wildcard ./live-sdk/tmp/$STAGE4))
	@echo "Error: stage4 not found: ${STAGE4}"
	@echo "make download first"
else
	mkdir -p mnt
	@echo "Setting up the stage4 please wait..."
	cd mnt && zcat ../live-sdk/tmp/${STAGE4} | sudo cpio -id
	mkdir -p {boot,dev,proc,sys}
endif

install:
	./utils/mount.sh
	./utils/exec.sh linux-libre.chsh
	sleep 1 && ./utils/umount.sh

