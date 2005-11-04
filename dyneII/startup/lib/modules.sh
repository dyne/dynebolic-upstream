# dyne:II startup scripts
# (C) 2005 Denis "jaromil" Rojo
# GNU GPL License

# Two types of modules are supported:
# 1) compressed (squashfs) filesystems with .dyne extension in dyne/modules
# 2) directories containing a VERSION file (not compressed) in dyne/SDK/modules

# security is a hot issue on modules: malicious modules could damage the system
# possible flaws are highlighted in this file
 
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

    # manual files
    if [ -x /opt/${mod}/share/man ]; then
      append_line /etc/zsh/modules \
        "export MANPATH=\$MANPATH:/opt/${mod}/share/man"
    fi

    # now source all the new paths
    source /etc/zsh/modules

    # configuration files in home directories
    # DANGER! this is a possible security flaw
    if [ -x /opt/${mod}/skel ]; then
      for h in `ls /home`; do
        cp -ura /opt/${mod}/skel/*  $h/
        cp -ura /opt/${mod}/skel/.* $h/
        cp -ura /opt/${mod}/skel/.* /etc/skel/
      done
    fi

    # execute initialization scripts in etc/rc_*
    # DANGER! this is also a possible security flaw
    if [ -x /opt/${mod}/etc ]; then
      for rc in `ls /opt/${mod}/etc | awk '/^rc.*/ {print $1}'`; do
        if [ -x /opt/${mod}/etc/$rc ]; then
          # call the rc script with module name as argument
          /opt/${mod}/etc/$rc ${mod}
        fi
      done
    fi
}



mount_sdk_modules() {

  if ! [ -x ${DYNE_SYS_MNT}/dyne/SDK/modules ]; then
    act "no modules found in the current SDK"
    return
  fi


  # use uncompressed modules in SDK
  for mod in `ls --color=none ${DYNE_SYS_MNT}/dyne/SDK/modules`; do

  #  mounted="`mount |grep ${mod} | uniq | awk '{ print $1 }'`"

    if ! [ -r ${DYNE_SYS_MNT}/dyne/SDK/modules/${mod}/VERSION ]; then
      error "SDK/module/${mod} is missing VERSION information, skipping.."
      continue
    fi 
    
    if [ -r /opt/${mod}/VERSION ]; then
      act "module ${mod} is already mounted in /opt"
#      act "close all it's applications in use and do:"
#      act "umount /opt/${mod}"
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

