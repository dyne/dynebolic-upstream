#!/bin/sh

# Copyright (C) 2023-2024 Dyne.org Foundation
#
# Designed, written and maintained by Denis Roio <jaromil@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, see <https://www.gnu.org/licenses/>.

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
