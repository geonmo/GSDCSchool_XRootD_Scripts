#!/bin/bash
WORKING_DIR=$(basename ${PWD})
PARENT_DIR=$(basename $(cd ..; basename $PWD ; cd -))


if [ "$WORKING_DIR" != "chapter2" ] || [ "$PARENT_DIR" != "solution" ];
then
	echo "This script must be run on solution/chapter2 dirs."
	exit
else
	echo "Starting Setup for chapter2."
fi

chmod +x make_blkdev.sh
sudo ./make_blkdev.sh

sudo umount /xrootdfs
sudo systemctl stop xrootd@myconf
sudo systemctl stop cmsd@myconf

sudo chown -R xrootd.xrootd /mnt/disk*

cp multidisk-wn.conf /etc/xrootd/xrootd-multidisk.cfg

sudo systemctl start cmsd@multidisk
sudo systemctl start xrootd@multidisk
