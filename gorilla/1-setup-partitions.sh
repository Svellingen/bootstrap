
#!/bin/bash
echo $HOSTNAME

echo "---- setup partitions ---"

sgdisk --clear \
         --new=1:0:+500MiB --typecode=1:ef00 --change-name=1:EFI \
         --new=2:0:0       --typecode=2:8e00 --change-name=2:crypt /dev/nvme0n1

echo "type passphrase"
read -s pass
echo "retype passphrase"
read -s passCheck

if [ "$pass" = "$passCheck" ]; then
       	echo "password match, continue"
    else
    echo "passwords not equal, exiting"
    exit
fi

# format drives
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

echo -n $pass | cryptsetup luksFormat --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/crypt -q
echo -n $pass | cryptsetup open /dev/disk/by-partlabel/crypt lvm

pvcreate --dataalignment 1m /dev/mapper/lvm
vgcreate volgroup0 /dev/mapper/lvm
lvcreate -L 50GB volgroup0 -n lv_root
lvcreate -l 100%FREE volgroup0 -n lv_home

modprobe dm_mod
vgscan
vgchange -ay

mkfs.ext4 /dev/volgroup0/lv_root
mount /dev/volgroup0/lv_root /mnt

mkdir /mnt/boot
mount /dev/disk/by-partlabel/EFI /mnt/boot

mkfs.ext4 /dev/volgroup0/lv_home
mkdir /mnt/home
mount /dev/volgroup0/lv_home /mnt/home

mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

echo "---- partitioning done ---"
