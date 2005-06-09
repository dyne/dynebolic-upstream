A Grub Boot Floppy for a Docked dyne:bolic
==========================================

This will allow a docked d:b to be booted without a cd for those cases
where no capable boot loader is installed on the docked system, and a
CD boot is not practical.

Copy the Image to a Floppy Disk
===============================

With a Linux system (such as dyne:bolic) use the command:

dd if=db-grub-floppy.img of=/dev/fd0

With a Windows system, use one of the rawrite utilities availble from:
http://www.fdos.org/ripcord/rawrite/
http://www.tux.org/pub/dos/rawrite/
http://uranus.it.swin.edu.au/~jn/linux/rawwrite.htm

Customizing
===========

If your docked system is on the first partition of the first drive, you
don't need to do any more. If this isn't the case, here is a way to get
things booting.

Boot with the floppy. When the grub menu appears, press the 'C' key, to
bring up the command prompt. At the 'grub>' prompt, issue a find command
and observe for the result as shown here:

grub> find /dyne/Linux
(hd0,5)

The part showing (hd0,5) in this example is the grub-style disk name of
the partition that is holding the docked d:b. Take note of the name shown
and press the Esc key to go back to the menu.

Test the boot by pressing 'E' on the highlighted 'Docked dyne:bolic' line.
The screen should show these three lines:

root (hd0,0)
kernel /dyne/Linux root=/dev/ram0 rw max_loop=128
initrd /dyne/initrd.gz

Highlight the 'root (hd0,0)' line using the cursor keys, and press 'E' to
edit that line. Change (hd0,0) to the value found before. Press enter, then
press 'B' to boot. Your docked d:b should boot.

To make the change permanent, edit the grub.conf file in the grub directory
on the floppy. Change the 'root (hd0,0)' line just like you did to boot in
the interactive mode before.

Credits
=======

This bootable floppy was packed together by Richard Griffith

The GRUB boot loader is GNU project: http://www.gnu.org/software/grub/

The working grub used to spawn this floppy image was part of a Fedora
Core 1 system: http://fedora.redhat.com/

The graphic background was adapted from a dyne:bolic background using
the gimp for color reduction and xpm formating.

jaromil made something wonderful enough to make this little sub-project
worth doing. Thanks for sharing your vision and efforts.


