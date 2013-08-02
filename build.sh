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

make defconfig
make
