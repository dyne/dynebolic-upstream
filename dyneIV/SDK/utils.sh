#!/bin/zsh

# small utils ripped from livesdk and zuper

act() { print " .  $*" }
notice() { print "[*] $*" }

devprocsys() {
	watdo="$1"
	werdo=mnt
	if [[ $watdo = mount ]]; then
		sudo mount -o bind /sys     $werdo/sys     && act "mounted sys"    && \
		sudo mount -t proc proc     $werdo/proc    && act "mounted proc"   && \
		sudo mount -o bind /dev     $werdo/dev     && act "mounted dev"    && \
		sudo mount -o bind /dev/pts $werdo/dev/pts && act "mounted devpts" && \
		return 0
	elif [[ $watdo = umount ]]; then
		sudo umount $werdo/dev/pts  && act "umounted devpts"
		sudo umount $werdo/dev      && act "umounted dev"
		sudo umount $werdo/proc     && act "umounted proc"
		sudo umount $werdo/sys      && act "umounted sys"
		return 0
	fi
	return 1
}

chroot-exec() {
	mkdir -p "log"

	_path=mnt
	_script=`basename "$1"`

	sudo sed -i "$_path/$_script" \
		-e 's@^#!/bin/sh@&\nexport DEBIAN_FRONTEND=noninteractive@' \
		-e 's@^#!/bin/sh@&\nexport LC_ALL=C@' \
		-e 's@^#!/bin/sh@&\nexport LANG=C@' \
		-e 's@^#!/bin/sh@&\nset -x ; exec 2>/'$_script'.log@'

	notice "Chrooting to execute '$_script' ..."
	sudo chmod +x "$_path/$_script"  || { return 1; }
	sudo chroot "$_path" "/$_script" || { return 1; }
}
