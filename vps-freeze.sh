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
sudo btrfs subvolume set-default @
cd
sudo umount /mnt/btrfs_root

#mount ulang
sudo mkdir /mnt/restore
sudo mount -o subvol=@ /dev/vda3 /mnt/restore
#set default ke sistem agar tidak bootlop ke GRML
sudo mount --bind /dev /mnt/restore/dev
sudo mount --bind /proc /mnt/restore/proc
sudo mount --bind /sys /mnt/restore/sys
sudo chroot /mnt/restore
sudo grub-reboot 0
sudo grub-set-default 'Ubuntu'
sudo update-grub
exit

sudo umount /mnt/restore
rm -rf /mnt/btrfs_root

sync
reboot
