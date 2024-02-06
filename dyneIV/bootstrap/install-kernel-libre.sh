#!/bin/sh

echo 'LANG="C"\nLANGUAGE="en_US:en"\nLC_ALL="C"\n' \
	 > /etc/default/locale

FREESH=freesh-archive-keyring_1.1_all.deb
dpkg -i /usr/src/${FREESH}
rm -f /usr/src/${FREESH}
# DEBIAN_FRONTEND=noninteractive apt-get update -q -y
# DEBIAN_FRONTEND=noninteractive apt-get install -q -y linux-libre-6.1*
