#!/bin/zsh

source utils.sh
# if arg is a file then copy it inside
[[ -r "$1" ]] && cp -v "$1" mnt/

chroot-exec `basename $1`
[[ -r mnt/`basename $1`.log ]] && {
	mkdir -p log
	mv -f "`basename $1`.log" "log/"
	cat log/`basename $1`
}

