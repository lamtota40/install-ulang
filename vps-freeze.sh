# Snapshoot
sudo mkdir -p /mnt/btrfs_root
sudo mount -o subvolid=5 /dev/vda3 /mnt/btrfs_root
cd /mnt/btrfs_root
sudo btrfs subvolume snapshot -r @ @clean
cd
sudo umount /mnt/btrfs_root

#restore dari GRML
#!/bin/bash
sudo mkdir -p /mnt/btrfs_root
sudo mount -o subvolid=5 /dev/vda3 /btrfs_root
cd /btrfs_root
sudo btrfs subvolume delete @
sudo btrfs subvolume snapshot @clean @
sudo btrfs subvolume delete @clean
sudo btrfs subvolume set-default @ /mnt/btrfs_root
cd
sudo umount /mnt/btrfs_root

#install ulang grub
sudo mount --bind /dev /mnt/restore/dev
sudo mount --bind /proc /mnt/restore/proc
sudo mount --bind /sys /mnt/restore/sys
sudo chroot /mnt/restore
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
#jika uefi##grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ubuntu
grub-install /dev/vda
sudo grub-reboot 0
sudo grub-set-default 'Ubuntu'
update-grub
update-initramfs -u
findmnt --verify --fstab
exit

sync
reboot
