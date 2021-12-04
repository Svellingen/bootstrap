#!/bin/bash

echo $HOSTNAME

echo "---- wiping disk ----"

# create a mapped container
#cryptsetup open --type plain $1 container --key-file /dev/urandom

# wipe container
#dd if=/dev/zero of=/dev/mapper/container status=progress bs=1M

# close container
#cryptsetup close container

echo "---- clear partitions ---"

# remove any partitioning on disk
sgdisk --zap-all /dev/nvme0n1


lsblk
echo "reboot if needed"
#reboot

