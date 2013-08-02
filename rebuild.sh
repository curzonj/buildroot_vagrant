#!/bin/sh

vagrant up
vagrant halt

rm package.box
vagrant package --base uclibc

vagrant box remove busybox virtualbox
vagrant box add busybox package.box
