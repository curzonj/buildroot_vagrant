#!/bin/bash

set -e
set -x

template_name=$1
future_disk=$2

function download {
  url=$1
  file=$(basename $url)
  dir=${file%%.tar*}

  [ -f $file ] || wget --quiet $url
  [ -d $dir ] || tar xf $file
}

# You can build it seperately or inside buildroot
#bzImagePath=linux-3.9.11/arch/x86/boot/bzImage
bzImagePath=buildroot/output/images/bzImage

initramfsPath=buildroot/output/images/rootfs.cpio.gz

if ! which git > /dev/null
then
  apt-get update
  apt-get -y install build-essential bc libncurses5-dev unzip extlinux vim git
fi

[ -d buildroot ] || git clone git clone git://git.buildroot.net/buildroot

if [ ! -d /usr/local/uclibc-toolchain-3.9 ]; then
  if [ -f /vagrant/toolchain_usr_local_uclibc-toolchain-3.9.tar.gz ]; then
    mkdir -p /usr/local/uclibc-toolchain-3.9
    tar -xf /vagrant/toolchain_usr_local_uclibc-toolchain-3.9.tar.gz -C /usr/local/uclibc-toolchain-3.9
  else
    # TODO download or build it
    exit 1
  fi
fi

[ -f $initramfsPath ] || (
  cd buildroot
  git clean -fdx
  make vagrant_defconfig
  make
)

[ -f $bzImagePath ] || (
  download https://www.kernel.org/pub/linux/kernel/v3.x/linux-3.9.11.tar.xz

  cd linux-3.9.11
  cp ../buildroot/board/vagrant/linux-3.9.11.config ./.config
  make oldconfig
  make
)

umount /dev/sdb1 || true

(echo ',,L,*' | sfdisk /dev/sdb) || partprobe

# Install the master boot record
cat /usr/lib/syslinux/mbr.bin > /dev/sdb

mkfs.ext4 /dev/sdb1
mount -t ext4 /dev/sdb1 /mnt

mkdir -p /mnt/boot

cp $bzImagePath /mnt/boot
cp $initramfsPath /mnt/boot/rootfs.cpio.gz

mkdir -p /mnt/etc/init.d
cp -a /vagrant/templates/$template_name/* /mnt/

# TODO this is the part that changes based on openstack
# vs vagrant, where do we find our rootfs
cat > /mnt/boot/syslinux.cfg <<EOS
PROMPT 0
TIMEOUT 1
DEFAULT core

LABEL core
  linux bzImage
  append initrd=rootfs.cpio.gz usrlocal=$future_disk
EOS

extlinux --install /mnt/boot
