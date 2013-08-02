This is repo will use an ubuntu virtualbox image via vagrant to run buildroot
and generate a bootable disk than can be turned into a VM image.

It's currently designed to load the rootfs on an initial ramfs. The build scripts
have no concept of pivoting to a disk-based root filesystem although they can
mount disk filesystems into the VFS tree.

## Quickstart

Make sure you have vagrant installed: http://www.vagrantup.com/

    vagrant up

That one command will give you a VDI file which is a virtualbox harddisk
image in busybox_os.vdi. The harddisk will be bootable. All you have to do
is stop the vagrant image, `vagrant halt`, create a custom virtualbox VM
and specify the busybox_os.vdi file as the first SATA disk of the new VM.

* You can rerun the build scripts anytime with `vagrant provision`
* If vagrant complains about disks being in use just run `vagrant reload`
* You can ssh into the build VM to inspect it with `vagrant ssh`

## Buildroot

buildroot is for building tiny embedded linux filesystems. Those embedded size
can be useful in more that just tiny devices. It can be used as a base for
highly customized servers, physical or virtual.

It's also useful for understanding how a linux systems works at it's most
basic level. The kernel, the rootfs, and the init script. It's hard to create
a linux system smaller than this. In the default config (at time of writing)
the rootfs is just under 700kB. The kernel is under 5MB.

## Templates

buildroot has 3 things to customize the resulting filesystem images it. In
order to preserve the tooling and scripts consistent between configurations,
we put different configurations in different "template" directories instead
of different git branches.

The [buildroots docs](http://buildroot.uclibc.org/downloads/manual/manual.html#rootfs-custom)
have all the details.

#### configs

By changing buildroot configs in the `configs` directory you can commit the
build configuration to version control.

#### overlay

The overlay directory is layed on top of the target file system bofore the
initial ramdisk is compiled.

#### scripts

there are pre and post scripts for when the rootfs.cpio.gz file is built. See
the buildroot docs for more on how those work.

## TODO

* eth0 isn't getting setup automatically (add eth0 to auto)
* shell doesn't have job control
* resolv.conf symlink is broken
* can't find the harddrive because /dev is messed up, use static dev
table

* disable the logger, usr/local can start it
* move the vagrant useradd and sshkey to usr/local, have
a common initrd file. No ssh keys in the initramfs
* generate a dynamic hostname (in usr/local)
* add my public key in the usr/local

* can we move the stuff into /boot on the harddrive to make it pretty

* mount the first disk we see at /usr/local and run /usr/local/etc/init.d/rcS
that can add SSH keys, launch stuff, point syslog at a server, enable swap, do
an ec2 cloud-init. It's like busybox is the base OS and /usr/local shell scripts
are the config management system that configures on first boot.
* build an impage that plays nice like cloud-init (on usr/local)

