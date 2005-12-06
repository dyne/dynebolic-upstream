
dyne:bolic has advanced thin client functionalities, they can be activated
using kernel boot options. at the boot: prompt, write 'linux' and then add
one or more of the following options:

 modules_ramdisk=eth_module  <- the kernel driver for your network card
                                it must be included in dyne/kernel dir

 network_boot=eth0,client_address <- the network configuration of the client

 mount_dock_samba=host_address  <- a dyne:II running on the same network

This will be enough to tell dyne:bolic to startup, configure a network card
and mount the system from another running dyne. With the configuration
'daemons=samba' (turned on by default) dyne:bolic will share it's own system
to host other computers.

All graphical applications will be running on the client, this setup helps
using devices that have no storage space to host a docked system.
If you want to open a remote X session and use the CPU power of another host,
you need to setup an open X server and then add this option to clients:

 x_remote=ip_address  <- ip address of the X server to connect at boot


