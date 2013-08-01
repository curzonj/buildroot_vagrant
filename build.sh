#!/bin/bash

set -e
set -x

function download {
  url=$1
  file=$(basename $url)
  dir=${file%%.tar*}

  [ -f $file ] || wget --quiet $url
  [ -d $dir ] || tar xf $file
}

sudo apt-get -y install build-essential bc libncurses5-dev unzip syslinux

# http://buildroot.uclibc.org/downloads/manual/manual.html#_using_buildroot
download http://buildroot.uclibc.org/downloads/buildroot-2013.05.tar.bz2

cd buildroot-2013.05

cp /vagrant/configs/defconfig ./
cp /vagrant/configs/linux_defconfig output/build/linux-3.9.11/arch/x86/configs/linux_defconfig

make defconfig
make

umount /dev/sdb1 || true

sudo sfdisk /dev/sdb <<"EOS"
,1,L,*
;
EOS

# Install the master boot record
cat /usr/lib/syslinux/mbr.bin > /dev/sdb

# TODO expand the rootfs onto here
mkfs.ext4 /dev/sdb2

mkfs.vfat /dev/sdb1
mount -t vfat /dev/sdb1 /mnt

cp output/images/bzImage /mnt
cp output/images/rootfs.cpio.gz /mnt

cat > /mnt/syslinux.cfg <<"EOS"
PROMPT 0
TIMEOUT 1
DEFAULT core

LABEL core
  LINUX bzImage
  INITRD rootfs.cpio.gz
EOS

# TODO switch to extlinux
syslinux -i /dev/sdb1
