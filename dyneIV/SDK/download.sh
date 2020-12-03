#!/bin/sh

if ! [ -r live-sdk ]; then
	git clone --recursive https://git.devuan.org/devuan-sdk/live-sdk
fi
mkdir -p live-sdk/tmp
cd live-sdk/tmp
echo "Download stage3 from sdk.dyne.org"
curl https://sdk.dyne.org:4443/job/dynebolic-live-base/lastSuccessfulBuild/artifact/tmp/bootstrap-devuan-amd64-stage3.cpio.gz -O
echo "Download stage4 from sdk.dyne.org"
curl https://sdk.dyne.org:4443/job/dynebolic-live-base/lastSuccessfulBuild/artifact/tmp/bootstrap-devuan-amd64-stage4.cpio.gz -O
cd -

