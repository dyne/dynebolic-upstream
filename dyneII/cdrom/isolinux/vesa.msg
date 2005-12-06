
To manually change the resolution in which dynebolic is going to boot,
you can use the video= parameter at the kernel boot: prompt, i.e:

 boot: linux video=vesafb:800x600-32

The video parameter sets the VESA mode in which you want to run your
console framebuffer, and eventually your XWindows.

In this version of dyne:bolic VESA mode is handled by Vesafb-tng, so
the previous configuration system has changed.

Here are most available modes:

640x480-16    640x480-32
              800x600-32
1024x768-16   1024x768-32

for a full list of modes supported by your videocard, once booted use
this command into an XTerminal:
 $ cat /proc/fb0/modes

dynebolic defaults: framebuffer video mode is 800x600-32
                    XWindows video mode is 1024x768-16


