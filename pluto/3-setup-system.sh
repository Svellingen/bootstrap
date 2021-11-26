#!/bin/bash

echo $HOSTNAME

echo "---   ---"

pacman -Syy

pacman -S --noconfirm linux linux-headers linux-lts linux-lts-headers

pacman -S --noconfirm vim
pacman -S --noconfirm git

pacman -S --noconfirm openssh
systemctl enable sshd

#pacman -S --noconfirm networkmanager wpa_supplicant wireless_tools netctl
#systemctl enable NetworkManager
pacman -S --noconfirm dialog

pacman -S --noconfirm lvm2

# time and date
timedatectl set-ntp true
timedatectl set-timezone Europe/Oslo
#systemctl enable systemd-timesyncd

# set hostname
hostnamectl set-hostname pluto

echo "127.0.0.1 localhost" >> /etc/hosts
echo "127.0.0.1 pluto" >> /etc/hosts


# Generate and set locale
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
localectl set-locale LANG=en_US.UTF-8

# vconsole
echo "KEYMAP=de-latin1" > /etc/vconsole.conf

# initramfs
sed -i 's/block filesystem/block encrypt lvm2 filesystem/g' /etc/mkinitcpio.conf
mkinitcpio -p linux
mkinitcpio -p linux-lts

#echo "set root user password"
#passwd
echo "--- adding user ---"
echo "username?"
read username

useradd -m -g users -G wheel $username

pacman -S --noconfirm sudo

sed -i '/(ALL) NOPASSWD/s/^# //g' /etc/sudoers

##
echo "--- grub / boot ---"
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

mkdir /boot/efi
mount /dev/sda1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub//locale/en.mo
sed -i '/GRUB_ENABLE_CRYPTODISK/s/^#//g' /etc/default/grub
sed -i 's/loglevel=3/cryptdevice=\/dev\/sda3:volgroup:0 loglevel=3/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


##
echo "--- create swap ---"
dd if=/dev/zero of=/swapfile bs=1M count=16384 status=progress
chmod 600 /swapfile
mkswap /swapfile
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab

##
echo "--- microcodes ---"
pacman -S --noconfirm intel-ucode

## video driver
pacman -S --noconfirm mesa

echo "exit chroot, umount -a, then reboot"






