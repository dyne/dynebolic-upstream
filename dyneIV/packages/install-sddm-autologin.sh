#!/bin/sh

mkdir -p /etc/sddm.conf.d
cat <<EOF > /etc/sddm.conf.d/autologin.conf
[Autologin]
User=dyne
Session=plasma
EOF
