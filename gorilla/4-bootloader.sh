#!/bin/bash

echo "--- grub / boot ---"
pacman -S --noconfirm grub efibootmgr dosfstools os-prober mtools

mkdir /boot/efi
mount /dev/nvme0n1p1 /boot/efi
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub//locale/en.mo
sed -i '/GRUB_ENABLE_CRYPTODISK/s/^#//g' /etc/default/grub
sed -i 's/loglevel=3/cryptdevice=\/dev\/nvme0n1p2:volgroup:0 loglevel=3/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "exit chroot, umount -a and reboot"
