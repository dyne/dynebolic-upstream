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
      append_line /boot/dynenv.modules "export PATH=\$PATH:/opt/${mod}/bin"
    fi
    
    # library files and pkg-config
    if [ -x /opt/${mod}/lib ]; then
     append_line /etc/ld.so.conf "/opt/${mod}/lib"
     if [ $APPEND_FILE_CHANGED = true ]; then # ld.so.conf gets modified
       NEWLIBPATH=true
#      we don't use LD_LIBRARY_PATH for modules anymore, takes too long loading
#      append_line /boot/dynenv.modules "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:/opt/${mod}/lib"
     fi
     append_line /boot/dynenv.modules \
       "export PKG_CONFIG_PATH=\$PKG_CONFIG_PATH:/opt/${mod}/lib/pkgconfig"
    fi

    # manual files
    if [ -x /opt/${mod}/share/man ]; then
      append_line /boot/dynenv.modules \
        "export MANPATH=\$MANPATH:/opt/${mod}/share/man"
    fi
    if [ -x /opt/${mod}/man ]; then
      append_line /boot/dynenv.modules \
        "export MANPATH=\$MANPATH:/opt/${mod}/man"
    fi

    # info files
    if [ -x /opt/${mod}/info ]; then
      append_line /boot/dynenv.modules \
        "export INFOPATH=\$INFOPATH:/opt/$mod/info"
    fi

    # locate database
    if [ -r /opt/${mod}/var/lib/locatedb ]; then
      append_line /boot/dynenv.modules \
        "export LOCATE_PATH=\$LOCATE_PATH:/opt/$mod/var/lib/locatedb"
    fi

    # python site-packages
    if [ -x /opt/${mod}/lib/python2.4/site-packages ]; then
      append_line /boot/dynenv.modules \
        "export PYTHONPATH=\$PYTHONPATH:/opt/$mod/lib/python2.4/site-packages"
    fi

    # configuration files in home directories
    # DANGER! this is a possible security flaw
    if [ -x /opt/${mod}/skel ]; then
      # copy the skel files in each user directory
      for h in `ls /home`; do
        for f in `ls -A /opt/${mod}/skel/`; do
          cp -ua /opt/${mod}/skel/${f} /home/${h}
        done
      done
      # copy the skel files in the /root directory
      for f in `ls -A /opt/${mod}/skel/`; do
        cp -ua /opt/${mod}/skel/${f} /root
      done
    fi

    # do we have also an etc/ directory in the module?
    if [ -x /opt/${mod}/etc ]; then

    # execute initialization scripts in etc/rc_*
    # DANGER! this is also a possible security flaw
      for rc in `ls /opt/${mod}/etc | awk '/^rc.*/ {print $1}'`; do
        if [ -x /opt/${mod}/etc/$rc ]; then
          if ! [ -d /opt/${mod}/etc/$rc ]; then
            # call the rc script with module name as argument
            /opt/${mod}/etc/$rc ${mod}
          fi
        fi
      done

    # add environment variables in /etc/env
    # DANGER! this is also a possible security flaw
      if [ -r /opt/${mod}/etc/env ]; then
        for env in `cat /opt/${mod}/etc/env | awk '!/^PATH=|LD_LIBRARY_PATH/ { print $0 }'`; do
          append_line /boot/dynenv.modules \
                      "export `echo $env | sed 's/export //'`"
        done
      fi

    fi # ... etc/
}



mount_sdk_modules() {

  if ! [ -x ${DYNE_SYS_MNT}/SDK/modules ]; then
    act "no modules found in the current SDK"
    return
  fi

  # flag to control whether to call ldconfig at the end
  NEWLIBPATH=false

  # mount only the single module specified in argument
  if [ $1 ]; then
    mod="$1"

    if ! [ -r ${DYNE_SYS_MNT}/SDK/modules/${mod}/VERSION ]; then
      error "SDK/module/${mod} is missing VERSION information"
      return
    fi
  
    if [ -r /opt/${mod}/VERSION ]; then
      act "module ${mod} is already mounted in /opt"
      act "close all it's applications in use and do:"
      act "umount /opt/${mod}"
      act "then run again \"dynesdk mount $mod\""
      return
    fi

    # uncompressed module
    mkdir -p /opt/${mod}

    mount -o bind ${DYNE_SYS_MNT}/SDK/modules/${mod} /opt/${mod}

    add_module_path ${mod}

    act "sdk module ${mod} mounted in /opt"

  # mount all available modules in SDK
  else

    # use uncompressed modules in SDK
    for mod in `ls --color=none ${DYNE_SYS_MNT}/SDK/modules`; do

    #  mounted="`mount |grep ${mod} | uniq | awk '{ print $1 }'`"

      if ! [ -r ${DYNE_SYS_MNT}/SDK/modules/${mod}/VERSION ]; then
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
  
      mount -o bind ${DYNE_SYS_MNT}/SDK/modules/${mod} /opt/${mod}

      add_module_path ${mod}

      act "sdk module ${mod} mounted in /opt"

    done

  fi

  if [ x$NEWLIBPATH = xtrue ]; then
    ld_regenerate_cache
  fi

}


mount_dyne_modules() {
    
    if ! [ -x ${DYNE_SYS_MNT}/modules ]; then
	act "no dyne modules found in ${DYNE_SYS_MNT}"
	return
    fi
    
  # flag to control whether to call ldconfig at the end
    NEWLIBPATH=false
    
    modvols=`grep mod /boot/volumes | awk '{print $3}'`
    if [ "$modvols" != "" ]; then

	for moddock in ${(f)modvols}; do

	    for mod in `find ${moddock}/dyne/modules/ -name '*.dyne'`; do
	  # squashed .dyne module
		
	  # get the name without path nor .dyne suffix
		mod_name=`basename ${mod} .dyne`
		
		if [ -r /opt/${mod_name}/VERSION ]; then
		    act "module ${mod_name} is already mounted, skipping.." 
		    continue
		fi
		
		mkdir -p /opt/${mod_name}
		
		mount -t squashfs -o loop,ro,suid ${mod} /opt/${mod_name}
		if [ $? != 0 ]; then #mount failed
		    error "failed mounting ${mod_name}"
		    continue
		fi  
		
		add_module_path ${mod_name}
		
		act "${mod_name} mounted in /opt"
		
	    done

# samba docks have no dyne subdir

	    for mod in `find ${moddock}/modules/ -name '*.dyne'`; do
	  # squashed .dyne module
		
	  # get the name without path nor .dyne suffix
		mod_name=`basename ${mod} .dyne`
		
		if [ -r /opt/${mod_name}/VERSION ]; then
		    act "module ${mod_name} is already mounted, skipping.." 
		    continue
		fi
		
		mkdir -p /opt/${mod_name}
		
		mount -t squashfs -o loop,ro,suid ${mod} /opt/${mod_name}
		if [ $? != 0 ]; then #mount failed
		    error "failed mounting ${mod_name}"
		    continue
		fi  
		
		add_module_path ${mod_name}
		
		act "${mod_name} mounted in /opt"
		
	    done

	done
    fi
    
  # now source all the new paths
    source /boot/dynenv.modules
    
    
    if [ x$NEWLIBPATH = xtrue ]; then
	ld_regenerate_cache
    fi
    
    
}


ld_regenerate_cache() {
  # check that /usr/lib is on the first line
  cat /etc/ld.so.conf | awk 'NR==1 { if ($0!="/usr/lib") {
                                        print "/usr/lib"
                                        print $0
                                     } else print $0
                                   }
                             NR!=1 { if ($0=="/usr/lib") next
                                     else print $0
                                   }' > /tmp/ld.so.conf
  cp -f /tmp/ld.so.conf /etc/ld.so.conf
  rm -f /tmp/ld.so.conf
  act "regenerating linkage cache in background"
  ldconfig &
} 

