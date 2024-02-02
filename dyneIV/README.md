# dyne:bolic IV :: software development kit

This folder contains all needed scripts and configurations to build a dyne:IV live bootable image.

## Quick Start

Install Qemu
```
apt-get install qemu-system-x86 qemu-utils ovmf
```

Download the latest ISO
```
make sync-iso
```

Run the ISO in Qemu
```
make qemu-usb
```

Create a persistent storage for emulator
```
make persist-create
```

## Usage

Root privileges are necessary on the build machine, because many operations require SUID access to devices etc. so please assume all following commands need to be run as root, either using sudo or doas or directly as root user.

The build will require approximately 6GB of space on your harddisk.

### 0. Install dependencies

Install all needed tools for development: this target is automated for APT based distros
```
make deps
```
Quick list of dependencies:
```
	apt-get install mmdebstrap squashfs-tools xorriso isolinux			\
    syslinux syslinux-efi syslinux-common syslinux-utils grub-pc-bin	\
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools				\
    squashfs-tools-ng pv schroot uidmap qemu-utils ovmf rsync wget xz-tools
```


### 2. Bootstrap a base image (stage2)

Create a **stage1** and **stage2** archive of the base system using Devuan Daedalus and the Linux Libre kernel by FSFLA.

```
make stage2
```

### 3. Install packages (stage3)

Install all default applications found in dyne:IV. Additional AppImages can be added later also by users, but this step will install a base list of packages from Devuan that we need in the system in any case.

```
make stage3
```

Look for `install-*.sh` files inside the `packages` subdir to see the lists, which are simply formatted with one package name per line, supporting comments. Please leave comments if you change them!

### 4. Pack the ISO

Create the bootable live iso that can run from a USB stick or a DVD or even in QEMU.

```
make iso
```

## Run in emulation

QEMU (KVM) can be used to run in emulation, also with a virtual harddisk providing persistence inside a qcow2 file.

Start the LIVE DVD emulator:
```
make qemu-dvd
```

Start the LIVE USB emulator:
```
make qemu-usb
```

Create a persitence file
```
make qemu-persistence
```

# Get in touch

We hang out on the Internet, connect any way you want, all channels
are bridged to the same room:

- https://socials.dyne.org/matrix-dynebolic
- https://socials.dyne.org/discord-dynebolic
- https://socials.dyne.org/telegram-dynebolic
