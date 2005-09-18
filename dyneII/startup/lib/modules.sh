# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

ID="$Id: $"

source /lib/dyne/utils.sh

activate_dyne_modules() {
  for mod in `ls --color=none ${DYNE_SYS_MNT}/dyne/modules`; do
	
	# 2 types of modules are supported:
	# directories containing a VERSION file (not compressed)
	# compressed (squashfs) filesystems with .dyne extension 

	if [ `echo $mod|cut -d. -f2` = dyne ]; then
		# squashed .dyne module

		act "TODO for module $mod .dyne not yet done"

	elif [ -r ${DYNE_SYS_MNT}/dyne/modules/${mod}/VERSION ]; then
		# uncompressed module

		mkdir -p /opt/${mod}
		mount -o bind ${DYNE_SYS_MNT}/dyne/modules/${mod} /opt/${mod}

		# binary files
		if [ -x /opt/${mod}/bin ]; then
		  echo "export PATH=\$PATH:/opt/${mod}/bin" >> /etc/zsh/modules
		fi

		# library files
		if [ -x /opt/${mod}/lib ]; then
		  echo "/opt/${mod}/lib" >> /etc/ld.so.conf
		fi

		act "uncompressed module ${mod}"

	else
		error "file ${DYNE_SYS_MNT}/dyne/modules/${mod} is not a dyne module"
	fi

   done
}
