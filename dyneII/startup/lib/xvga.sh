#!/bin/zsh

# this is the dyne:bolic vga autodetection for Xorg
# this script recognizes most vga cards in a very simple way
# only sed is used
#
# (C) 2003-2006 Denis "Jaromil" Roio


# This source code is free software; you can redistribute it and/or
# modify it under the terms of the GNU Public License as published 
# by the Free Software Foundation; either version 2 of the License,
# or (at your option) any later version.
#
# This source code is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Please refer to the GNU Public License for more details.
#
# You should have received a copy of the GNU Public License along with
# this source code; if not, write to:
# Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA


source /lib/dyne/utils.sh


detect_x_driver() {

# config file is created in ramdisk
CFG=/etc/X11/xorg.conf

# distributed template in module
DISTCFG=/etc/X11/xorg.conf.dist

## special fix in dyne 2.0
# we don't use anymore Xorg as a module
# it is included in the core so it is writable
# to let easy installation of third-party drivers
# but we have to keep the old build path:
mkdir -p /opt
ln -s /usr/X11R6 /opt/Xorg

if [ -e $CFG ]; then return; fi

notice "detecting VGA video card:"
VGACARD="`lspci | grep VGA`"
act "${VGACARD}"

if [ "`lspci | grep -i ' vmware'`" ]; then
  act "using X 'vmware' driver for your virtual machine"
  sed "s/fbdev/vmware/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep Unknown`" ]; then
  act "using framebuffer video device for unknown card"
  cp $DISTCFG $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -iE 'nvidia| riva| viper| tnt|geforce' | grep -v Unknown`" ]; then
  act "using X 'nv' driver for your nVidia card"
  sed "s/fbdev/nv/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -i ' matrox'`" ]; then
  act "using X 'mga' driver for your Matrox card"
  # write the X config
  sed "s/fbdev/mga/g" $DISTCFG > $CFG
  # load the kernel DRM module
  loadmod mga
  return
fi

if [ "`echo ${VGACARD} | grep -iE ' intel.*8'`" ]; then
  act "using X 'i810' driver for your Intel card"
  sed "s/fbdev/i810/g" $DISTCFG > $CFG
  loadmod i810
#  loadmod i830     - obsoleted?
  loadmod i915
  return
fi

if [ "`echo ${VGACARD} | grep -i ' neomagic'`" ]; then
  act "using X 'neomagic' driver for your Neomagiccard"
  sed "s/fbdev/neomagic/g" $DISTCFG > $CFG
  return
fi
 
if [ "`echo ${VGACARD} | grep -i ' ati'`" ]; then
  # try specific ATI cards: radeon or r128
  if [ "`echo ${VGACARD} | grep -i ' radeon'`" ]; then
    act "using X 'radeon' driver for your Radeon card"
    sed "s/fbdev/radeon/g" $DISTCFG > $CFG
    act "loading Radeon direct rendering module"
    loadmod radeon
    return
  fi

  if [ "`echo ${VGACARD} | grep -i ' r128 '`" ]; then
    act "using the X 'r128' driver for your r128 card" 
    sed "s/fbdev/r128/g" $DISTCFG > $CFG
    act "loading R128 direct rendering module"
    loadmod r128
    return
  fi

  # load the mach64 kernel module if it's one
  if [ "`echo ${VGACARD} | grep -i ' mach64 '`" ]; then
    act "loading Mach64 direct rendering module"
    loadmod mach64 
  fi

  # fallback on the generic ati driver
  act "using X 'ati' driver for your Ati card"
  sed "s/fbdev/ati/g" $DISTCFG > $CFG
  return
fi


if [ "`echo ${VGACARD} | grep -i 'savage'`" ]; then
  act "using X 'savage' driver for your Savage card"
  sed "s/fbdev/savage/g" $DISTCFG > $CFG
  act "loading Savage direct rendering module"
  loadmod savage
  return
fi

if [ "`echo ${VGACARD} | grep -i ' Virge'`" ]; then
  act "using X 's3virge' driver for your S3 Virge card"
  sed "s/fbdev/s3virge/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -i ' s3 '`" ]; then
  act "using X 'S3' driver for your S3 card"
  sed "s/fbdev/s3/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep 'SiS'`" ]; then
  # don't use sis driver for SiS6325 because it fallsback on 640x480
  # it is a device present on some gericom laptop //jrml 12/5/03 zagreb
  # -- i expect it to be fixed by now in Xorg //jrml 29/5/06 amsterdam
  # if [ "`echo ${VGACARD} | grep -i ' 6325'`" ]; then return; fi
  act "using X 'sis' driver for your SiS card"
  sed "s/fbdev/sis/g" $DISTCFG > $CFG
  act "loading SiS direct rendering module"
  loadmod sis
  return
fi

if [ "`echo ${VGACARD} | grep -i ' voodoo'`" ]; then
  act "using X 'tdfx' driver for your Voodoo card"
  sed "s/fbdev/tdfx/g" $DISTCFG > $CFG
  act "loading 3dfx direct rendering module"
  loadmod tdfx
  return
fi

if [ "`echo ${VGACARD} | grep -i ' cirrus'`" ]; then
  act "using X 'cirrus' driver for your Cirrus card"
  sed "s/fbdev/cirrus/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -i ' cyrix'`" ]; then
  act "using X 'cyrix' driver for your Cirrus card"
  sed "s/fbdev/cyrix/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -i ' i128'`" ]; then
  act "using X 'i128' driver for your I128 card"
  sed "s/fbdev/i128/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -iE ' intel.*74'`" ]; then
  act "using X 'i740' driver for your i740 card"
  sed "s/fbdev/i740/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -i ' rendition'`" ]; then
  act "using X 'rendition' driver for your Rendition card"
  sed "s/fbdev/rendition/g" $DISTCFG > $CFG
  return
fi

if [ "`echo ${VGACARD} | grep -iE ' silicon.*motion'`" ]; then
  act "using X 'siliconmotion' driver for your SiliconMotion card"
  sed "s/fbdev/siliconmotion/g" $DISTCFG > $CFG
  return
fi

if [ "`lspci | grep -i ' trident '`" ]; then
  act "using X 'trident' driver for your Trident card"
  sed "s/fbdev/trident/g" $DISTCFG > $CFG
  return
fi

if [ "`lspci | grep -i ' tseng '`" ]; then
  act "using X 'tseng' driver for your Tseng card"
  sed "s/fbdev/tseng/g" $DISTCFG > $CFG
  return
fi



# fallback to framebuffer device
# the link is not forced: if we put our own XF86Config
# it will be used, overriding the fbdev fallback
act "no special driver needed, using VESA framebuffer device"
act "(you can't change resolutions other than 800x600x16bpp)"
cp $DISTCFG $CFG


}
