#!/bin/bash

set -e
set -x

if mount | grep sdb1
then
  umount /dev/sdb1
fi

# sfdisk frequently fails to re-read the partition
# layout and wants us to manually run partprobe
echo '1,,L,*' | sudo sfdisk /dev/sdb || partprobe

mkfs.ext4 /dev/sdb1
mount -t ext4 /dev/sdb1 /mnt

CORE=http://cdimage.ubuntu.com/ubuntu-core/releases/13.04/release/ubuntu-core-13.04-core-amd64.tar.gz
CORE_TAR=$(basename $CORE)
[ -f $CORE_TAR ] || wget --quiet $CORE

tar -xf $CORE_TAR -C /mnt

cp /etc/resolv.conf /mnt/etc
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
mount --bind /dev /mnt/dev

cat > /mnt/etc/apt/sources.list <<"END_APT"
deb http://archive.ubuntu.com/ubuntu/ raring main restricted multiverse
deb http://archive.ubuntu.com/ubuntu/ raring-updates main restricted multiverse
deb http://archive.ubuntu.com/ubuntu/ raring-security main restricted multiverse
END_APT

cp /var/cache/apt/archives/*.deb /mnt/var/cache/apt/archives/

#  1. /dev/sda (??? MB; ???)  3. - /dev/sdb1 (??? MB; /)
#  2. /dev/sdb (??? MB; ???)
#
#(Enter the items you want to select, separated by spaces.)
#
#GRUB install devices:
yes 2 | env LC_ALL=C chroot /mnt bash -c 'apt-get update && apt-get -y install linux-generic'

# We install build-essential because we need it for the virtulabox guest
# additions and vagrant is a dev env, so you're probably going to be compiling
# anyways.
env LC_ALL=C chroot /mnt apt-get -y install curl wget openssh-server sudo net-tools resolvconf build-essential virtualbox-guest-dkms

env LC_ALL=C chroot /mnt bash <<"END_CHROOT"
echo "root:vagrant"|chpasswd

useradd vagrant
echo "vagrant:vagrant"|chpasswd

addgroup vagrant adm
addgroup vagrant sudo
END_CHROOT

echo vagrant-core > /mnt/etc/hostname

mkdir -p /mnt/root/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key' > /mnt/root/.ssh/authorized_keys
chmod -R go-rwx /mnt/root/.ssh

echo 'UseDNS no' >> /mnt/etc/ssh/sshd_config

cat > /mnt/etc/sudoers <<"END_SUDOERS"
Defaults        env_reset
Defaults        !mail_badpass
Defaults        env_keep="SSH_AUTH_SOCK"
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

root   ALL=(ALL:ALL) ALL
%sudo  ALL=(ALL:ALL) NOPASSWD:ALL
#includedir /etc/sudoers.d
END_SUDOERS

cp /mnt/var/cache/apt/archives/*.deb /var/cache/apt/archives/

env LC_ALL=C chroot /mnt apt-get clean

umount /mnt/proc
umount /mnt/sys
umount /mnt/dev

rm /mnt/etc/resolv.conf

exit 0

apt-get -y install extlinux

# The grub dialog is just a side effect of packages.
cat /usr/lib/syslinux/mbr.bin > /dev/sdb

cat > /mnt/boot/syslinux.cfg <<"EOS"
PROMPT 0
TIMEOUT 1
DEFAULT core

LABEL core
        LINUX vmlinuz-3.8.0-27-generic
        APPEND root=/dev/sda1 ro
        INITRD initrd.img-3.8.0-27-generic
EOS

extlinux --install /mnt/boot
