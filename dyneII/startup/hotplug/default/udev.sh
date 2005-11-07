#!/bin/zsh

# dyne:II hotplug system

# send hotplug event to udevd for serialization
# see udevsend(8)

/sbin/udevsend $@

