# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

ID="$Id: $"

source /lib/dyne/utils.sh

activate_dyne_modules() {

   # regenerate /etc/zsh/modules
   rm /etc/zsh/modules
   touch /etc/zsh/modules

  # Two types of modules are supported:
  # 1) compressed (squashfs) filesystems with .dyne extension in dyne/modules
  # 2) directories containing a VERSION file (not compressed) in dyne/SDK/modules
  # to select the second, use the sdk=true flag on the kernel boot
  SDK=`get_config sdk`  
    if [ -x ${DYNE_SYS_MNT}/dyne/SDK/modules -a $SDK ]; then # use uncompressed modules in SDK
	
	for mod in `ls --color=none ${DYNE_SYS_MNT}/dyne/SDK/modules`; do
	    
	    if [ -r ${DYNE_SYS_MNT}/dyne/SDK/modules/${mod}/VERSION ]; then

		# uncompressed module
		mkdir -p /opt/${mod}
		mount -o bind ${DYNE_SYS_MNT}/dyne/SDK/modules/${mod} /opt/${mod}
		
		# binary files
		if [ -x /opt/${mod}/bin ]; then
		  echo "export PATH=\$PATH:/opt/${mod}/bin" >> /etc/zsh/modules
		fi

		# library files
		if [ -x /opt/${mod}/lib ]; then
		  echo "/opt/${mod}/lib" >> /etc/ld.so.conf
		  echo "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/opt/${mod}/lib/pkgconfig" \
			>> /etc/zsh/modules
		fi

		act "uncompressed module ${mod}"
		
	    fi

	done
	
    elif [ -x ${DYNE_SYS_MNT}/dyne/modules ]; then
	
	for mod in `ls --color=none ${DYNE_SYS_MNT}/dyne/modules`; do
	    
	    if [ `echo $mod|cut -d. -f2` = dyne ]; then
		# squashed .dyne module
		
		act "TODO for module $mod"
		
	    fi
	    
	done
	
    fi

    
}
