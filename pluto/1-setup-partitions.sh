
#!/bin/bash
echo $HOSTNAME

echo "---- setup partitions ---"

sgdisk --clear \
         --new=1:0:+500MiB --typecode=1:ef00 --change-name=1:EFI \
         --new=2:0:+16GiB  --typecode=2:8200 --change-name=2:swap \
         --new=3:0:0       --typecode=3:8e00 --change-name=3:crypt /dev/sda

echo "type passphrase"
read -s pass
echo "retype passphrase"
read -s pass2

if [ "$pass" = "$pass2" ]; then
       	echo "password match, continue"
    else
    echo "passwords not equal, exiting"
    exit
fi

# format drives
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI
mkfs.ext4 /dev/disk/by-partlabel/swap

echo -n $pass | cryptsetup luksFormat --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/crypt -q
echo -n $pass | cryptsetup open /dev/disk/by-partlabel/crypt lvm

pvcreate --dataalignment 1m /dev/mapper/lvm
vgcreate volgroup0 /dev/mapper/lvm
lvcreate -L 50GB volgroup0 -n lv_root
lvcreate -l 100%FREE volgroup1 -n lv_home

modprobe dm_mod
vgscan
vgchange -ay

mkfs.ext4 /dev/volgroup0/lv_root
mount /dev/volgroup1/lv_root /mnt

mkdir /mnt/boot
mount /dev/disk/by-partlabel/EFI /mnt/boot

mkfs.ext4 /dev/volgroup1/lv_home
mkdir /mnt/home
mount /dev/volgroup1/lv_home /mnt/home

mkdir /mnt/etc
genfstab -U -p /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab


# Bring Up Encrypted Swap
#cryptsetup open --type plain --key-file /dev/urandom /dev/disk/by-partlabel/cryptswap swap
#mkswap -L swap /dev/mapper/swap
#swapon -L swap



