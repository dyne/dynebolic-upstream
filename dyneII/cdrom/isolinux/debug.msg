
To debug dyne:bolic boot process you can activate interactive
prompt for loading kernel modules.

At the "boot:" prompt below, type "linux modules_prompt=true"
or "linux modules_deny=comma,separated,list" to give a list
of modules that should not be loaded. These options can be made
permanent by placing the setting inside the dyne.cfg file.


In case your mouse and/or keyboard don't work, try:

 boot: linux nohid

If your computer doesn't boots correctly (especially laptops), try
also with one of the options below, or more than one combined:

 boot: linux noapic
 boot: linux acpi=off
 boot: linux ide0=ata66 ide1=ata66

and don't forget to search online about the Linux kernel support
of your computer model: often you'll discover you're not alone!


