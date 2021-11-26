#!/bin/bash

echo $HOSTNAME

echo "--- installing ----"

cp -r /root/bootstrap /mnt/

pacstrap /mnt base base-devel git


echo "now : arch-chroot /mnt"
