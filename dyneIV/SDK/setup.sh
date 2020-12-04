#!/bin/zsh
source utils.sh
cpio=live-sdk/tmp/bootstrap-devuan-amd64-stage4.cpio.gz
[[ -r $cpio ]] || {
	print "error: cpio not found $cpio"
	return 1
}

# decompress cpio in mnt
mkdir -p mnt
[[ -r mnt/etc/inittab ]] || {
	notice "Setting up the stage4 please wait..."
	pushd mnt
	zcat ../$cpio | sudo cpio -id
	mkdir -p {boot,dev,proc,sys}
	popd
}

# setup repos
./mount.sh
./exec.sh linux-libre.chsh
./umount.sh

