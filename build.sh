#!/bin/bash

set -e
set -x

template_name=$1

function download {
  url=$1
  file=$(basename $url)
  dir=${file%%.tar*}

  [ -f $file ] || wget --quiet $url
  [ -d $dir ] || tar xf $file
}

sudo apt-get -y install build-essential bc libncurses5-dev unzip extlinux

# http://buildroot.uclibc.org/downloads/manual/manual.html#_using_buildroot
download http://buildroot.uclibc.org/downloads/buildroot-2013.05.tar.bz2

cd buildroot-2013.05

cp /vagrant/templates/$template_name/configs/defconfig ./
cp /vagrant/templates/$template_name/configs/linux_defconfig \
  output/build/linux-3.9.11/arch/x86/configs/linux_defconfig

make defconfig
make

umount /dev/sdb1 || true

sudo sfdisk /dev/sdb <<"EOS"
,,L,*
EOS

# Install the master boot record
cat /usr/lib/syslinux/mbr.bin > /dev/sdb

mkfs.ext4 /dev/sdb1
mount -t ext4 /dev/sdb1 /mnt

# TODO can 
cp output/images/bzImage /mnt
cp output/images/rootfs.cpio.gz /mnt

cat > /mnt/syslinux.cfg <<"EOS"
PROMPT 0
TIMEOUT 1
DEFAULT core

LABEL core
  linux bzImage
  append initrd=rootfs.cpio.gz
EOS

extlinux --install /mnt
