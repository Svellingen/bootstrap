#!/bin/bash

echo $HOSTNAME

echo "--- installing ----"

pacstrap /mnt base base-devel git


echo "now : arch-chroot /mnt"
