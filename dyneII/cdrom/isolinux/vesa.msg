To manually change the resolution in which dynebolic is going to boot,
you can use the vga= parameter at the kernel boot: prompt.

The vga parameter sets the VESA mode in which you want to run your
console framebuffer, and eventually your XWin.

Here are available modes and numbers:

              Resolution 640x480 800x600 1024x768 1280x1024 1600x1200
Colors
256 (8bit)               769     771     773      775       796
32768 (15bit)            784     787     790      793       797
65536 (16bit)            785     788     791      794       798
16.8M (24bit)            786     789     792      795       799

dynebolic default is 788 = 16bit 800x600

