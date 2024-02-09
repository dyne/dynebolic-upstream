#!/bin/bash

DEPS="gettext gcc g++ qt5-qmake qtbase5-dev libqt5quick5 qtdeclarative5-dev"

# temporary install of needed packages
DEBIAN_FRONTEND=noninteractive \
	apt-get install -q -y ${DEPS}

pushd /usr/src

tombver=2.10
[ -r /usr/local/bin/tomb ] || {
	>&2 echo " install Tomb from latest source"
	[ -r Tomb-${tombver}.tar.gz ] ||
		wget https://files.dyne.org/tomb/Tomb-${tombver}.tar.gz
	rm -rf Tomb-${tombver}
	tar xf Tomb-${tombver}.tar.gz
	pushd Tomb-${tombver}
	make install
	pushd extras/translations && make install \
		&& popd
	pushd extras/qt-tray && qmake && make && cp tomb-qt-tray /usr/local/bin \
		&& popd
	pushd extras/kdf-keys && make && make install \
		&& popd
	popd # Tomb
	rm -rf Tomb-${tombver}*
}

[ -r /usr/local/share/jaromail ] || {
	>&2 echo " install Jaromail from latest source"
	git clone --depth 1 https://github.com/dyne/jaromail
	pushd jaromail
	make
	make install
	popd
	rm -rf jaromail
}

[ -r /usr/local/bin/zenroom ] || {
	>&2 echo " install Zenroom from latest binary builds"
	wget https://github.com/dyne/Zenroom/releases/latest/download/zenroom
	wget https://github.com/dyne/Zenroom/releases/latest/download/zencode-exec
	chmod 755 zenroom zencode-exec
	mv zenroom zencode-exec /usr/local/bin
}

[ -r /root/.dotfiles ] || {
	>&2 echo " install Jaromil's dotfiles"
	wget https://jaromil.dyne.org/dotfiles.sh
	bash dotfiles.sh
	pushd /root/.dotfiles && make && popd
	export HOME=/home/dyne
	setuidgid dyne bash dotfiles.sh
	pushd /home/dyne/.dotfiles && setuidgid dyne make && popd
	rm -f dotfiles.sh
}

DEBIAN_FRONTEND=noninteractive \
	apt-get remove --purge -q -y ${DEPS}
DEBIAN_FRONTEND=noninteractive \
	apt-get autoremove -q -y
