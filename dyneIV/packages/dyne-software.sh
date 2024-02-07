#!/bin/bash

pushd /usr/src

>&2 echo " install Tomb from latest source"
wget https://files.dyne.org/tomb/Tomb-2.10.tar.gz
tar xf Tomb-2.10.tar.gz
pushd Tomb-2.10
make install
pushd extras/translations && make install && popd
pushd extras/qt-tray && qmake && make && cp tomb-qt-tray /usr/local/bin && popd
pushd extras/kdf-keys && make && make install && popd
popd # Tomb-2.10
rm -rf Tomb-2.10*

>&2 echo " install Jaromail from latest source"
git clone --depth 1 https://github.com/dyne/jaromail
pushd jaromail
make
make install
popd
rm -rf jaromail

>&2 echo " install Zenroom from latest binary builds"
wget https://github.com/dyne/Zenroom/releases/latest/download/zenroom
wget https://github.com/dyne/Zenroom/releases/latest/download/zencode-exec
chmod 755 zenroom zencode-exec
mv zenroom zencode-exec /usr/local/bin

>&2 echo " install Jaromil's dotfiles"
wget https://jaromil.dyne.org/dotfiles.sh
bash dotfiles.sh
pushd /root/.dotfiles && make && popd
export HOME=/home/dyne
setuidgid dyne bash dotfiles.sh
pushd /home/dyne/.dotfiles && setuidgid dyne make && popd
rm -f dotfiles.sh
