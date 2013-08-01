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

sudo apt-get -y install build-essential bc libncurses5-dev unzip

#download https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.9.11.tar.xz

#[ -f linux-3.9.11/arch/x86/boot/bzImage ] || (cd linux-3.9.11 && make defconfig && make)

# http://buildroot.uclibc.org/downloads/manual/manual.html#_using_buildroot
download http://buildroot.uclibc.org/downloads/buildroot-2013.05.tar.bz2

cd buildroot-2013.05

cp /vagrant/configs/defconfig ./
cp /vagrant/configs/linux_defconfig output/build/linux-3.9.11/arch/x86/configs/linux_defconfig

make defconfig
make

exit 0

umount /dev/sdb1 || true

echo '1,,L,*' | sudo sfdisk /dev/sdb

mkfs.ext4 /dev/sdb1
mount -t ext4 /dev/sdb1 /mnt

grub-install --root-directory=/mnt /dev/sdb
