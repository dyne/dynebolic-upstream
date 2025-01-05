#!/bin/sh

echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' \
	 > /etc/default/locale

FREESH=freesh-archive-keyring_1.1_all.deb
DEBIAN_FRONTEND=noninteractive apt install -q -y /usr/src/${FREESH}

# fruity - hold on with with rm -rf
#rm -f /usr/src/${FREESH}

# metapackages informations keep breaking on mirrors sides - fruity
DEBIAN_FRONTEND=noninteractive apt-get update -q -y
DEBIAN_FRONTEND=noninteractive apt install -q -y \
	linux-image-6.12.8-gnu #linux-libre-lts linux-libre-lts-headers

# fruity - i added the specification of the version for the kernel
# and I commented the removal of the sources because we'll need it
#rm -f /etc/apt/sources.list.d/freesh.sources


