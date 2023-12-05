#!/bin/sh

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
 net-tools bash-completion bsdextrautils tree
