#!/bin/sh
# Copyright (C) 2023-2024 Dyne.org Foundation
#
# Designed, written and maintained by Denis Roio <jaromil@dyne.org>
#
# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  Please refer
# to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, see <https://www.gnu.org/licenses/>.

# misc base utilities and shell prompt

[ -r /root/.dotfiles ] || {
	curl -S https://jaromil.dyne.org/dotfiles.sh --output /dotfiles.sh
	bash  /dotfiles.sh && cd /root/.dotfiles && make setup
	rm -f /dotfiles.sh
}

DEBIAN_FRONTEND=noninteractive \
apt-get install -y -q \
 wget make vim-tiny xxd daemontools \
 zsh fzf tmux htop iotop suckless-tools git \
 software-properties-common apt-transport-https jq mosh direnv \
 mtr-tiny pwgen silversearcher-ag liblnk-utils vbetool \
 net-tools bash-completion bsdextrautils tree less \
 iputils-ping pciutils usbutils rsyslog man-db file \
 ifupdown ethtool isc-dhcp-client isc-dhcp-common nmap smbclient
