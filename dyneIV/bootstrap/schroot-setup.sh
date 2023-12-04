#!/bin/sh
mkdir -p /etc/schroot/dyne
cat <<EOF > /etc/schroot/dyne/copyfiles
/etc/resolv.conf
EOF

cat <<EOF > /etc/schroot/dyne/nssdatabases
services
protocols
networks
hosts
EOF

cat <<EOF > /etc/schroot/dyne/fstab
/proc          /proc           none    rw,bind         0       0
/sys           /sys            none    rw,bind         0       0
/dev           /dev            none    rw,bind         0       0
/dev/pts       /dev/pts        none    rw,bind         0       0
/tmp           /tmp            none    rw,bind         0       0
/run           /run            none    rw,bind         0       0
/run/lock      /run/lock       none    rw,bind         0       0
/dev/shm       /dev/shm        none    rw,bind         0       0
/run/shm       /run/shm        none    rw,bind         0       0
/var/run/gdm3  /var/run/gdm3   none    rw,bind         0       0
/var/lib/dbus  /var/lib/dbus   none    rw,bind         0       0
EOF
