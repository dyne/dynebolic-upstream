#!/bin/sh

echo "Acquire::Retries \"5\";" > /etc/apt/apt.conf.d/avoid-timeouts
echo 'DPkg::options { "--force-confdef"; };' >  /etc/apt/apt.conf.d/force-confdef
echo 'APT::Install-Recommends "true";' > /etc/apt/apt.conf.d/recommends
echo 'APT::Install-Suggests "false";' > /etc/apt/apt.conf.d/suggests

# commented out by fruity for a more granular choice down the system and modules
#echo "deb http://deb.debian.org/debian bookworm-backports main" > ${ROOT}/etc/apt/sources.list.d/bookworm-backports.list
#cat << EOF > /etc/apt/preferences.d/99bookworm-backports
#Package: *
#Pin: release n=bookworm-backports
#Pin-Priority: 900
#EOF
