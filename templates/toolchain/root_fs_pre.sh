#!/bin/sh

DIR=$1
cd $HOST_DIR/usr

tar -czf /vagrant/buildroot-toolchain.tar.gz .
