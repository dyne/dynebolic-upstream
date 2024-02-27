#!/bin/sh

if [ "`id -u`" -ne "0" ]; then
	echo "needs suid to execute: run as root using 'su -c' or sudo"
	exit 1
fi
