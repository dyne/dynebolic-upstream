#!/bin/zsh

R=`pwd`
cpio=$R/live-sdk/tmp/bootstrap-devuan-amd64-stage4.cpio.gz
[[ -r $cpio ]] || {
	print "error: cpio not found $cpio"
	return 1
}
mkdir -p mnt
pushd mnt
zcat $cpio | sudo cpio -id
mkdir -p {boot,dev,proc,sys}
popd
