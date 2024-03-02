# dyne:bolic IV :: software development kit

Repository upstream: https://git.devuan.org/jaromil/dynebolic

Tools here are useful to develop dyne:bolic, but not necessary to use it.

For more information on how to use dyne:bolic go to https://dynebolic.org

## Quick Start

Use a Debian based system like Devuan or Ubuntu.

Clone the repository and enter the dyneIV folder. We will call this directory the "SDK".

Always run commands as root and have the GNU `make` tool installed.

The build will require approximately 6GB of space on your harddisk.

Install developer dependencies:
```
make deps
```

Download the latest development ROOT: 
```
make setup
```

Build the system components (will take a while...):
```
make system
```

Thanks for your patience! Once you arrived here, you will not need to repeat the steps above anymore.

Your SDK is ready for development and test cycles.

Create the live bootable ISO (filename `dynebolic.iso`):
```
make iso
```

Run the ISO in Qemu
```
make qemu
```

While inside the emulator, hack around and export any changes made:
```
sudo dyne-snapshot
```
The default root password is `dyne`.

Switch off the emulator, download the snapshot file inside the SDK.

To test the snapshot file (fill DATE and RANDOM with real filename):
```
make snap-test FILE=dyneIV-snapshot-DATE-RANDOM.squashfs
```

This will create a new `dynebolic.iso` file (and overwrite the old one). 

Run the qemu emulator again (`make qemu`) to check how your changes are working, if they are OK then look into the snapshot file and find out what to commit inside the `static` directory.

```
make snap-mount FILE=dyneIV-snapshot-DATE-RANDOM.squashfs
ncdu snap-mount
tree snap-mount
...
make snap-umount
```

To make a final test of what you have added to `static` and apt packages:
```
make system
make iso
make qemu
```

To burn the `dynebolic.iso` on a USB drive, check the device path (use `dmesg` after inserting) and then burn baby burn! 
```
make burn USB=/dev/sd?                                                       
```

Happy hacking!

## Usage manual

### Overview of SDK commands

```
✨ Welcome to the Dyne:IV SDK by Dyne.org!
🛟 Usage: make <target>
👇🏽 List of targets:
 ----             __ Quick start:
 deps             🛠️ Install development dependencies
 setup            📥 Download the latest development ROOT modules
 system           🗿 Build the root system: dyneIV-root
 iso              🏁 Create the current ISO image
 qemu             🖥️ Emulate UEFI USB boot using qemu
 burn             🔥 Write the ISO to a removable USB=/dev/sd?
 _               
 -----            __ More emulator functions:
 qemu-isolinux    📀 Emulate DVD boot using qemu
 qemu-spice       🖥️ Emulate via SPICE (requires LAN client)
 _               
 -----            __ Snapshot testing functions:
 snap-iso         🧨 Test a squashed snapshot as ISO FILE=path
 snap-mount       👀 Explore the contents of a snapshot FILE=path
 snap-umount      🔌 Stop exploring and unplug the snapshot
 _               
 -----            __ Build from scratch:
 bootstrap        🚀 Build the base system: dyneIV-bootstrap
 system           🗿 Build the root system: dyneIV-root
 modules          🧩 Build all system modules (takes long...)
 upgrade          🔝 Update root system packages
 iso              🏁 Create the current ISO image
 _               
 -----            __ Undo and restart from scratch
 reset            ♻️  Reset current ROOT to the latest downloaded
 restrap          ♻️  Reset current ROOT to base bootstrap stage
 clean            🧹  Delete ROOT
```

### Bootstrap a base image

Create a **stage1** and **stage2** archive of the base system using Devuan Daedalus and the Linux Libre kernel by FSFLA.

```
make bootstrap
```

### Install all system packages

Install all default applications found in dyne:IV. Additional AppImages can be added later also by users, but this step will install a base list of packages from Devuan that we need in the system in any case.

```
make system
```

Look for `*-apt.txt` files inside the `system` subdir to see the lists, which are simply formatted with one package name per line, supporting comments. Please leave comments if you change them!

### Install all modules

Additional modules can be added using the SDK. The default modules built are:

- `kde` for the desktop
- `multimedia` for all sort of media applications
- `games` for having fun

In order to install all these modules one has just to launch the command:
```
make modules
```

Look for `*-apt.txt` files inside the `modules` subdir to see the list of packages.

### Pack the ISO

Create the bootable live iso that can run from a USB stick or a DVD or even in QEMU.

```
make iso
```

If you want help burning the USB then make sure to know its device and do:
```
make burn USB=/dev/sd?
```

## Run in emulation

QEMU (KVM) can be used to run in emulation, also with a virtual harddisk providing persistence inside a qcow2 file.

Start the LIVE DVD emulator:
```
make qemu-isolinux
```

Start the LIVE USB emulator:
```
make qemu
```

Create a persitence file
```
make persistence-create
```

# Get in touch

We hang out on the Internet, connect any way you want, all channels
are bridged to the same room:

- https://socials.dyne.org/matrix-dynebolic
- https://socials.dyne.org/discord-dynebolic
- https://socials.dyne.org/telegram-dynebolic
