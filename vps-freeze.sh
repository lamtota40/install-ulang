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
cd
sudo umount /mnt/btrfs_root

sync
reboot
