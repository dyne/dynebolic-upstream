#!/bin/sh

echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' \
	 > /etc/default/locale

FREESH=freesh-archive-keyring_1.1_all.deb
dpkg -i /usr/src/${FREESH}
# fruity - hold on with with rm -rf
#rm -f /usr/src/${FREESH}

DEBIAN_FRONTEND=noninteractive apt-get update -q -y
DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
	linux-image-6.6.67-gnu linux-headers-6.6.67-gnu

# fruity - i added the specification of the version for the kernel
# and I commented the removal of the sources because we'll need it
#rm -f /etc/apt/sources.list.d/freesh.sources

# test - move linux packages to root for safekeeping
cp /var/cache/apt/archives/linux-*-gnu-1.0_amd64.deb /root/

