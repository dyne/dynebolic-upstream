#!/bin/zsh
#
# dyne:bolic X startup script
# by jaromil
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published 
# by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Please refer to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, write to:
# Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA


FILE_ID="\$Id: rc.X,v 1.3 2004/06/19 18:16:04 jaromil Exp $"

######## VOLATILE MODE
if [ -r /tmp/volatile ]; then exit 0; fi

source /lib/dyne/utils.sh
source /lib/dyne/wmaker.sh
source /etc/LANGUAGE

######## ASCII MODe
ASCII="`get_config ascii`"
if [ $ASCII ]; then
    notice "ASCII mode entered"
    touch /tmp/ascii

# startup gpm
    gpm -m /dev/psaux -t ps2

## setup the interactive shell prompt
    if [ -r /etc/zshrc ]; then rm /etc/zshrc; fi
    cat > /etc/zshrc <<EOF
# here is the motd
cd
echo "you are running `uname -mnrsp`"
echo "uptime: `/usr/bin/uptime`"
echo
fortune -s
echo
EOF
    exit 0;
fi

## full dyne mode
touch /tmp/dyne

## setup the interactive shell prompt for X
if [ -r /etc/zshrc ]; then rm /etc/zshrc; fi
cat > /etc/zshrc <<EOF
# here is the motd
cd
echo "you are running `uname -mnrsp`"
echo "uptime: `/usr/bin/uptime`"
echo
fortune -s
echo
EOF


# generate windowmaker volumes entries
wmaker_gen_volumes


exit 0

