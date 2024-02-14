#!/bin/sh

echo "Acquire::Retries \"5\";" > /etc/apt/apt.conf.d/avoid-timeouts
echo 'DPkg::options { "--force-confdef"; };' >  /etc/apt/apt.conf.d/force-confdef
echo 'APT::Install-Recommends "false";' > /etc/apt/apt.conf.d/recommends
echo 'APT::Install-Suggests "false";' > /etc/apt/apt.conf.d/suggests
