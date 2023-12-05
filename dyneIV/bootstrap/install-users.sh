#!/bin/sh

# default pass is luther

ROOT_PASS='$y$j9T$07JXuzf/4me/gbFvyaam5/$6BjD46Fe5gVdzvvb5PKgHumZer3hepPN6rzWH3Pnj1A'
LUTHER_PASS='$y$j9T$0OtPX2yRJMRFZfTrIlT62.$sXO3x8dCF6a4XS.fggk/aWvdjXQ.QcrQUd7btE6qf77'
echo "Reset root password (luther)"
echo "root:${ROOT_PASS}" | chpasswd -e
if ! grep luther /etc/passwd > /dev/null; then
echo "Setup luther user"
	useradd -m -u 1000 -p "${LUTHER_PASS}" -s /bin/bash luther
fi
echo "Set dynebolic hostname"
echo "dynebolic" > /etc/hostname
#TODO: somehow this changes to ubuntu, is it live-boot?
