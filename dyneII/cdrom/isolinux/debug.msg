
To debug dyne:bolic boot process you can activate the 'interactive'
option by sending this parameter to the kernel.

At the "boot:" prompt below, type:

 boot: linux interactive

In case your mouse and/or keyboard don't work, try:

 boot: linux nohid

If your computer doesn't boots correctly (especially laptops), try
also with one of the options below, or more than one combined:

 boot: linux noapic
 boot: linux acpi=off
 boot: linux ide0=ata66 ide1=ata66

and don't forget to search online about the Linux kernel support
of your computer model: often you'll discover you're not alone!


