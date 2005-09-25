# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

ID="$Id: $"
   
# Two types of modules are supported:
# 1) compressed (squashfs) filesystems with .dyne extension in dyne/modules
# 2) directories containing a VERSION file (not compressed) in dyne/SDK/modules
 
source /lib/dyne/utils.sh

add_module_path() {
    # takes a /opt/module path as argument
    mod=$1

    # binary files
    if [ -x /opt/${mod}/bin ]; then
      append_line /etc/zsh/modules "export PATH=\$PATH:/opt/${mod}/bin"
    fi
    
    # library files
    if [ -x /opt/${mod}/lib ]; then
#     append_line /etc/ld.so.conf "/opt/${mod}/lib"
     append_line /etc/zsh/modules "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/${mod}/lib"
     append_line /etc/zsh/modules \
       "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/opt/${mod}/lib/pkgconfig"
    fi
}

mount_sdk_modules() {

  if ! [ -x ${DYNE_SYS_MNT}/dyne/SDK/modules ]; then
    act "no modules found in the current SDK"
    return
  fi

  # use uncompressed modules in SDK
  for mod in `ls --color=none ${DYNE_SYS_MNT}/dyne/SDK/modules`; do

    mounted="`mount |grep ${mod} | uniq | awk '{ print $1 }'`"
    
    if [ -x $mounted ]; then
      act "module ${mod} is already mounted in /opt"
      act "close all it's applications in use and do:"
      act "umount /opt/${mod}"
      continue
    fi
	    
    if ! [ -r ${DYNE_SYS_MNT}/dyne/SDK/modules/${mod}/VERSION ]; then
      error "SDK/module/${mod} is missing VERSION information, skipping.."
      continue
    fi 

    # uncompressed module
    mkdir -p /opt/${mod}

    mount -o bind ${DYNE_SYS_MNT}/dyne/SDK/modules/${mod} /opt/${mod}

    add_module_path ${mod}

    act "sdk module ${mod} mounted in /opt"
		

  done

}


mount_compressed_modules() {

    if ! [ -x ${DYNE_SYS_MNT}/dyne/modules ]; then
      act "no dyne modules found in ${DYNE_SYS_MNT}/dyne"
      return
    fi
	
    for mod in `find ${DYNE_SYS_MNT}/dyne/modules/ -name '*.dyne'`; do
	  # squashed .dyne module
	    
	  # get the name without path nor .dyne suffix
	  mod_name=`basename ${mod} .dyne`

          if [ -r /opt/${mod_name}/VERSION ]; then
            act "module ${mod_name} is already mounted, skipping.." 
            continue
          fi
	    
	  mkdir -p /opt/${mod_name}

	  mount -t squashfs -o loop ${mod} /opt/${mod_name}
          if [ $? != 0 ]; then #mount failed
            error "failed mounting ${mod_name}"
            continue
          fi  
	    
	  add_module_path ${mod_name}

	  act "${mod_name} mounted in /opt"
	    
     done
}

