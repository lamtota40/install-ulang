# Snapshoot
sudo mkdir -p /mnt/btrfs_root
sudo mount -o subvolid=5 /dev/sda1 /mnt/btrfs_root
cd /mnt/btrfs_root
sudo btrfs subvolume snapshot -r @ @clean
sudo btrfs subvolume snapshot -r @home @home_clean

#restore dari GRML
mount -o subvolid=5 /dev/sda1 /mnt
cd /mnt
btrfs subvolume delete @
btrfs subvolume snapshot @clean @
sync
reboot
