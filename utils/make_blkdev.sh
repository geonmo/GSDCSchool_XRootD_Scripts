#!/bin/bash
sudo mkdir /blockdev
cd /blockdev
sudo dd if=/dev/zero of=dev01.img bs=1G count=1
sudo dd if=/dev/zero of=dev02.img bs=1G count=1
sudo losetup /dev/loop0 /blockdev/dev01.img
sudo losetup /dev/loop1 /blockdev/dev02.img

sudo mkfs.xfs /dev/loop0
sudo mkfs.xfs /dev/loop1

sudo mkdir -p /mnt/disk01
sudo mkdir -p /mnt/disk02

sudo mount -t xfs /dev/loop0 /mnt/disk01
sudo mount -t xfs /dev/loop1 /mnt/disk02
