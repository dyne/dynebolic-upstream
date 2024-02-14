#!/bin/bash

# To check which files need restoring perms look into static
# also look for unusual perms into ROOT/etc
# sudo find ROOT/etc -printf '%m %p\0' | xargs --null -n1 | grep -v 777 | grep -v 755 | grep -v 644

>&2 echo "Fixing permissions in ROOT folders..."
chown -R root:root /etc /home /lib /lib64 \
	  /media /mnt /opt /root /run /sbin /srv /var

# chown clears suid & guid permission bits occasionally set under /bin & /usr/bin, only change ownership when not root:root already

find /bin \! -user root -o \! -group root -exec chown root:root '{}' \;
find /usr \! -user root -o \! -group root -exec chown root:root '{}' \;

# WARNING: SUID BIT
chmod 4754 \
	  /usr/lib/dbus-1.0/dbus-daemon-launch-helper
# /usr/sbin/pppd
# chmod 3775 \
# 	  /usr/share/ppd/custom

chown -R dyne:dyne /home/dyne
chmod 755 /etc/sddm.conf.d \
	  /etc/sysctl.d \
	  /etc/sudoers.d \
	  /etc/pam.d \
	  /etc/apt /etc/apt/apt.conf.d /etc/apt/sources.list.d \
	  /etc/apt/keyrings /etc/apt/trusted.gpg.d /etc/apt/auth.conf.d \
	  /etc/apt/preferences.d
chmod 700 \
	  /etc/polkit-1/rules.d \
	  /etc/ssl/private
chmod 644 \
	  /etc/pam.d/* \
	  /etc/sysctl.d/* \
	  /etc/apt/sources.list.d/* \
	  /etc/apt/preferences.d/*
chmod 640 \
	  /etc/gshadow* \
	  /etc/shadow*
chmod 440 \
	  /etc/sudoers.d/* \
	  /etc/sudoers

# chmod 750 \
# 	  /usr/libexec/sssd/proxy_child \
# 	  /usr/libexec/sssd/krb5_child \
# 	  /usr/libexec/sssd/ldap_child \
# 	  /usr/libexec/sssd/selinux_child

# chmod 744 \
# 	  /usr/lib/cups/backend-available/lpd \
# 	  /usr/lib/cups/backend-available/usb \
# 	  /usr/lib/cups/backend-available/dnssd \
# 	  /usr/lib/cups/backend/implicitclass \
# 	  /usr/lib/cups/backend/mdns \
# 	  /usr/lib/cups/backend/lpd \
# 	  /usr/lib/cups/backend/usb \
# 	  /usr/lib/cups/backend/serial \
# 	  /usr/lib/cups/backend/dnssd

# chmod 444 \
# 	  /usr/lib/udev/hwdb.bin


# Notes:
#
# save working permissions on a system
# find / -name '*' -printf '%m %p\0' > working-permissions.txt
#
# show working permissions saved
# xargs --null -n1 --arg-file=working-permissions.txt echo | less
#
# apply working permissions saved to /mnt/broken
# perl -0ne '$_ =~ m{^(\d*\d\d\d) (.*)\0$} ; print "chmod $1 $2\n" ; chmod oct($1), "/mnt/broken/$2" ;' working-permissions.txt
#
# explanation:
# https://superuser.com/questions/1252600/fix-permissions-of-server-after-accidental-chmod-debian
