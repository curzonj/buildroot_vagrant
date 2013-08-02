#!/bin/sh

image_dir=$1

umount /dev/sdb1 || true

sudo sfdisk /dev/sdb <<"EOS"
,,L,*
EOS

# Install the master boot record
cat /usr/lib/syslinux/mbr.bin > /dev/sdb

mkfs.ext4 /dev/sdb1
mount -t ext4 /dev/sdb1 /mnt

cp $image_dir/bzImage /mnt
cp $image_dir/rootfs.cpio.gz /mnt

cat > /mnt/syslinux.cfg <<"EOS"
PROMPT 0
TIMEOUT 1
DEFAULT core

LABEL core
  linux bzImage
  append initrd=rootfs.cpio.gz
EOS

extlinux --install /mnt
