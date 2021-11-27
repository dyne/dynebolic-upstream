#!/bin/zsh

source utils.sh
# if arg is a file then copy it inside
if [[ -r "$1" ]]; then
	cp -v "$1" mnt/
elif [[ -r "install-scripts/$1" ]]; then
	cp -v "install-scripts/$1" mnt/
else
	echo "Install script not found: $1"
	return 1
fi

notice "Executing script in chroot: $1"
chroot-exec `basename $1`
[[ -r mnt/`basename $1`.log ]] && {
	mkdir -p log
	mv -f "`basename $1`.log" "log/"
	cat log/`basename $1`
	act "output saved to log/$1.log"
}
rm -f /mnt/"$1"
act "execution completed."
