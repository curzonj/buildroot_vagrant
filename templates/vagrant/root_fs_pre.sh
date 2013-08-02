#!/bin/sh

DIR=$1

mv $DIR/etc/inittab $DIR/etc/inittab.bak
sed 's/getty/getting -a root/' $DIR/etc/inittab.bak > $DIR/etc/inittab
rm $DIR/etc/inittab.bak

chroot $DIR /bin/sh <<"END_CHROOT"
grep vagrant /etc/passwd || /usr/sbin/adduser -s /bin/ash -D vagrant

chown -R vagrant $DIR/home/vagrant
chmod -R go-rwx $DIR/home/vagrant/.ssh
END_CHROOT
