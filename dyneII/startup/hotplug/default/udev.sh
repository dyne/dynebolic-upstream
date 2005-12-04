#!/bin/ash

# dyne:II hotplug system

# send hotplug event to udevd for serialization
# see udevsend(8)

#if [ $RUNLEVEL != 0 -a $RUNLEVEL != 6 ]; then
  /sbin/udevsend $@
#fi

