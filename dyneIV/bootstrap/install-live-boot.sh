#!/bin/sh

apt-get -q -y install mount live-boot zstd direnv \
		openrc sysvinit-core psmisc e2fsprogs orphan-sysvinit-scripts

cat <<EOF > /etc/live/boot.conf
MINIMAL=false
PERSISTENCE_FSCK=false
DISABLE_NTFS=true
DISABLE_FUSE=true
DISABLE_DM_VERITY=true
EOF

echo "sd_mod" > /etc/initramfs-tools/modules

# Use Quad9 as default DNS
echo "nameserver 9.9.9.9" > /etc/resolv.conf

cat <<EOF > /etc/hosts
127.0.0.1       localhost
127.0.1.1       dynebolic
127.0.0.1       ip6-localhost ip6-loopback
EOF
update-initramfs -k all -c
