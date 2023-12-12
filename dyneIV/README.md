# dyne:bolic IV :: software development kit

This folder contains all needed scripts and configurations to build a dyne:IV live bootable image.

## Usage

Root privileges are necessary on the build machine, because many operations require SUID access to devices etc. so please assume all following commands need to be run as root, either using sudo or doas or directly as root user.

The build will require approximately 6GB of space on your harddisk.

### 0. Install dependencies

Install all needed tools for development: this target is automated for APT based distros
```
make development-deps
```
Quick list of dependencies:
```
	apt-get install mmdebstrap squashfs-tools xorriso isolinux			\
    syslinux syslinux-efi syslinux-common syslinux-utils grub-pc-bin	\
    grub-efi-amd64-bin grub-efi-ia32-bin mtools dosfstools				\
    squashfs-tools-ng pv schroot uidmap qemu-utils ovmf
```


### 2. Bootstrap a base image

Create a **stage1** and **stage2** archive of the base system using Devuan Daedalus and the Linux Libre kernel by FSFLA.

```
make bootstrap
```

### 3. Install packages

Install all default applications found in dyne:IV. Additional AppImages can be added later also by users, but this step will install a base list of packages from Devuan that we need in the system in any case.

```
make packages
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
make qemu
```

Start the LIVE USB emulator:
```
make qemu-uefi
```

Create a persitence file
```
make qemu-persistence
```

# Get in touch

We are hanging out on https://t.me/dynebolic


