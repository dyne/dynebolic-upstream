#!/bin/sh
# added by fruity to clean up the discovery package manager

DEBIAN_FRONTEND=noninteractive \
apt-get --purge remove -y -q \
	plasma-discover-common plasma-discover

apt-get -q -y autoremove && apt-get clean && apt-get autoclean

