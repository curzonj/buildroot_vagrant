#!/bin/bash

set -e
set -x

if [ ! -d buildroot ]
then
  sudo apt-get update
  sudo apt-get -y install build-essential bc libncurses5-dev unzip extlinux vim git

  git clone git clone git://git.buildroot.net/buildroot

  # TODO download the toolchain and build the FS
fi
