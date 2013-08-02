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

    vagrant package --base NAME_OF_CUSTOM_VM

Then you'll have a package.box file in the directory. For more information
about vagrant package see [the slightly outdated docs](http://docs-v1.vagrantup.com/v1/docs/base_boxes.html).

## Buildroot

buildroot is for building tiny embedded linux filesystems. Those embedded size
can be useful in more that just tiny devices. It can be used as a base for
highly customized servers, physical or virtual.

It's also useful for understanding how a linux systems works at it's most
basic level. The kernel, the initramfs, and the init script. It's hard to create
a linux system smaller than this.

It's like busybox is the base OS and /usr/local shell scripts
are the config management system that configures on first boot.

## TODO

* remove my key from the template

* move the kernel out of the buildroot system
* add aufs to the kernel
* setup swap
* build an impage that plays nice like cloud-init (on usr/local)
* put the tool chain in /usr/local in the vagrant image
* switch back to devtmpfs
* shell on the console doesn't have job control
* test to -x for rcS with error message
