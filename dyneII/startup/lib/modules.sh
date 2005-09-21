# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

ID="$Id: $"

source /lib/dyne/utils.sh

add_module_path() {
    # takes a /opt/module path as argument
    mod=$1
    
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
}

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

		add_module_path ${mod}

		act "uncompressed module ${mod}"
		
	    fi

	done
	
    elif [ -x ${DYNE_SYS_MNT}/dyne/modules ]; then
	
	for mod in `find ${DYNE_SYS_MNT}/dyne/modules/ -name '*.dyne'`; do

	    # squashed .dyne module
	    
	    # get the name without path nor .dyne suffix
	    mod_name=`basename ${mod} .dyne`
	    
	    mkdir -p /opt/${mod_name}
	    mount -t squashfs -o loop ${mod} /opt/${mod_name}
	    
	    add_module_path ${mod_name}

	    act "${mod_name}"
	    
	done
	
    fi

    
}
