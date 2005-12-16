#!/bin/sh

# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo - GNU GPL License

# dyne:II ACPI handler

# this script gets called on every ACPI event catched in /etc/acpi/events

PATH="/usr/bin:/usr/sbin:/bin:/sbin"

logger -t acpi -p syslog.info "$@"

HI=`echo $1 | cut -d/ -f1`
LO=`echo $1 | cut -d/ -f2 | cut -d' ' -f1`

if [ "$HI" = "button" ]; then

	if [ "$LO" = "power" ]; then

		init 0

	fi

fi

