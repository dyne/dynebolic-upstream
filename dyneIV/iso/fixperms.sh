#!/bin/bash
set -e
# To check which files need restoring perms look into static
# also look for unusual perms into ROOT/etc
# sudo find ROOT/etc -printf '%m %p\0' | xargs --null -n1 | grep -v 777 | grep -v 755 | grep -v 644

#>&2 echo "Fixing permissions in ROOT folders..."
chown -R root:root /root
chmod 700 /root
chown -R dyne:dyne /home/dyne
chmod 700 /home/dyne
# chown clears suid & guid permission bits occasionally set under /bin & /usr/bin
find /etc /home /lib /lib64 /media /mnt /opt /sbin /srv /usr /var /bin \
	 -not -path /usr/share -not -path /var/cache/apt \
	 \! -user root -o \! -group root -exec \
	 chown root:root '{}' \;
# find / -not -path /proc -type d -exec chmod go-w '{}' \;
# find /bin \! -user root -o \! -group root -exec chown root:root '{}' \;
# find /usr \! -user root -o \! -group root -exec chown root:root '{}' \;
# chmod -R go-w      /etc /lib /lib64 /opt /bin /sbin /usr/bin /usr/sbin
# Set particular ownerships
chown root:messagebus \
	/usr/lib/dbus-1.0/dbus-daemon-launch-helper
chown root:staff \
    /usr/local/share/fonts
chown root:utmp \
    /usr/lib/x86_64-linux-gnu/utempter/utempter
chown root:tty \
    /usr/lib/mc/cons.saver \
    /usr/bin/write \
    /usr/bin/wall \
    /usr/bin/ssh-agent
chown root:shadow \
    /usr/bin/expiry \
    /usr/bin/chage \
    /sbin/unix_chkpwd \
    /etc/shadow- \
    /etc/shadow \
    /etc/gshadow- \
    /etc/gshadow
chown root:games \
    /usr/games/tecnoballz \
    /usr/games/lbreakout2
chown root:crontab \
    /usr/bin/crontab
chown polkitd:root \
    /usr/share/polkit-1/rules.d \
    /etc/polkit-1/rules.d

# WARNING: granting SUID BIT
chmod 4755 \
    /usr/lib/polkit-1/polkit-agent-helper-1 \
    /usr/lib/openssh/ssh-keysign \
    /usr/bin/sudo \
    /usr/bin/schroot \
    /usr/bin/pkexec \
    /usr/bin/passwd \
    /usr/bin/newuidmap \
    /usr/bin/newgrp \
    /usr/bin/newgidmap \
    /usr/bin/gpasswd \
    /usr/bin/chsh \
    /usr/bin/chfn \
    /bin/umount \
    /bin/su \
    /bin/ntfs-3g \
    /bin/mount \
    /bin/fusermount3 \
    /usr/lib/dbus-1.0/dbus-daemon-launch-helper
chmod 2775 \
    /usr/local/share/fonts
chmod 2755 \
    /usr/lib/x86_64-linux-gnu/utempter/utempter \
    /usr/lib/mc/cons.saver \
    /usr/bin/write \
    /usr/bin/wall \
    /usr/bin/ssh-agent \
    /usr/bin/expiry \
    /usr/bin/chage \
    /sbin/unix_chkpwd \
    /usr/games/tecnoballz \
    /usr/games/lbreakout2 \
    /usr/bin/crontab
chmod 1777 \
    /run/screen \
    /run/lock
# chmod 3775 \
# 	  /usr/share/ppd/custom


#####
# /etc
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
