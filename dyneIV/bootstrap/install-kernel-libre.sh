#!/bin/sh

echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' \
	 > /etc/default/locale

FREESH=freesh-archive-keyring_1.1_all.deb
dpkg -i /usr/src/${FREESH}
rm -f /usr/src/${FREESH}
DEBIAN_FRONTEND=noninteractive apt-get update -q -y
DEBIAN_FRONTEND=noninteractive apt-get install -q -y \
	linux-image-5.15.173-gnu linux-headers-5.15.173-gnu

# fruity - i added the specification of the version for the kernel
# and I commented the removal of the sources because we'll need it
#rm -f /etc/apt/sources.list.d/freesh.sources
