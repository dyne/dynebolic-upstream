#!/bin/sh

FREESH=freesh-archive-keyring_1.1_all.deb

curl https://linux-libre.fsfla.org/pub/linux-libre/freesh/pool/main/f/freesh-archive-keyring/${FREESH} --output ${FREESH}
dpkg -i /${FREESH}
rm -f ROOT/${FREESH}
apt-get update
apt-get -q -y install linux-libre-6.1*
