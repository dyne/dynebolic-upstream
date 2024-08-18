#!/bin/bash

#TMP_DEPS="gcc g++ libgcrypt20-dev qt5-qmake qtbase5-dev qtdeclarative5-dev"
TMP_DEPS=""

[ -r /usr/local/bin/tomb ] && [ -r /usr/local/share/jaromail ] && \
[ -r /usr/local/bin/zenroom ] && [ -r /usr/local/bin/hasciicam ] && \
[ -r /usr/local/bin/flask ] && {
	>&2 echo "-- Dyne.org software found already installed."
	exit 0
}

function deps() {
	# temporary install of needed packages
	DEBIAN_FRONTEND=noninteractive \
		apt-get install -q -y $*
	TMP_DEPS="$TMP_DEPS $*"
}

pushd /usr/src

tombver=2.11
[ -r /usr/local/bin/tomb ] || {
	rm -rf Tomb-${tombver}*
	deps g++ libgcrypt20-dev qt5-qmake qtbase5-dev qtdeclarative5-dev
	>&2 echo " install Tomb from latest source"
	[ -r Tomb-${tombver}.tar.gz ] ||
		wget https://files.dyne.org/tomb/releases/Tomb-${tombver}.tar.gz
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
	rm -rf jaromail
	deps gcc
	>&2 echo " install Jaromail from latest source"
	git clone --depth 1 https://github.com/dyne/jaromail
	pushd jaromail
	make
	make install
	popd
	rm -rf jaromail
}

[ -r /usr/local/bin/zenroom ] || {
	rm -f zenroom zencode-exec
	>&2 echo " install Zenroom from latest binary builds"
	wget https://github.com/dyne/Zenroom/releases/latest/download/zenroom
	wget https://github.com/dyne/Zenroom/releases/latest/download/zencode-exec
	chmod 755 zenroom zencode-exec
	mv zenroom zencode-exec /usr/local/bin
}

[ -r /usr/local/bin/hasciicam ] || {
	rm -rf hasciicam
	deps gcc libaa1-dev autoconf automake
	git clone https://github.com/jaromil/hasciicam.git
	pushd hasciicam && \
		autoreconf -i && automake && ./configure && \
		make && make install && popd
	rm -rf hasciicam
}

# python flask for splash
DEBIAN_FRONTEND=noninteractive \                                                                                                                                                                apt-get install -q -y python3-dotenv python3-greenlet python3-asgiref python3-pip
pip install flask



DEBIAN_FRONTEND=noninteractive \
	apt-get remove --purge -q -y ${TMP_DEPS}
DEBIAN_FRONTEND=noninteractive \
	apt-get autoremove -q -y
