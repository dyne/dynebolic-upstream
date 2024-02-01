#!/bin/bash

[ -r /var/guix ] && exit 0

# TODO: support other architectures here
ARCH="x86_64"
VERSION="1.4.0"
RELEASE=guix-binary-${VERSION}.${ARCH}-linux.tar.xz 

pushd /tmp

[ -r ${RELEASE} ] || wget https://ftp.gnu.org/gnu/guix/${RELEASE}

wget 'https://sv.gnu.org/people/viewgpg.php?user_id=15145' -q - | gpg --import -

wget https://ftp.gnu.org/gnu/guix/${RELEASE}.sig
gpg --verify ${RELEASE}.sig

tar --warning=no-timestamp -xf ${RELEASE}
rm -rf /var/guix && mv var/guix /var/
rm -rf /gnu && mv gnu /

popd

mkdir -p ~root/.config/guix
ln -sf /var/guix/profiles/per-user/root/current-guix ~root/.config/guix/current

# make guix available to all users
mkdir -p /usr/local/bin
pushd /usr/local/bin
ln -sf /var/guix/profiles/per-user/root/current-guix/bin/guix
popd

# link the info manual
mkdir -p /usr/local/share/info
pushd /usr/local/share/info
for i in /var/guix/profiles/per-user/root/current-guix/share/info/* ;
  do ln -sf $i ; done
popd

# authorize substitutes for binary packages
#guix archive --authorize < ~root/.config/guix/current/share/guix/ci.guix.gnu.org.pub

