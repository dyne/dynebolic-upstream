#!/bin/sh
#
# made for use on Devuan Beowulf
#
# reqs: zsh debootstrap
#
# bootstrap is done over jenkins, don't use for local development

if ! [ -r live-sdk ]; then
	git clone --recursive https://git.devuan.org/devuan-sdk/live-sdk
fi
cd live-sdk
sed -i 's/firmware-linux//' config
git apply ../live-sdk.patch
mkdir -p blends/dynebolic
cp ../dynebolic-desktop.blend blends/dynebolic/desktop.blend
cp ../desktop-config ../config blends/dynebolic/
zsh -f -c 'source sdk && load devuan dynebolic && \
	release=chimaera && \
	version=4.0.0 && \
	bootstrap_complete_base'
cd -

