# Snapshoot
sudo mkdir -p /mnt/btrfs_root
sudo mount -o subvolid=5 /dev/sda1 /mnt/btrfs_root
cd /mnt/btrfs_root
sudo btrfs subvolume snapshot -r @ @clean
sudo btrfs subvolume snapshot -r @home @home_clean
cd

#restore dari GRML
mount -o subvolid=5 /dev/sda1 /mnt
cd /mnt
btrfs subvolume delete @
btrfs subvolume snapshot @clean @
sync
reboot

mount -o subvolid=5 /dev/sda1 /mnt
cd /mnt
ls

# Hapus subvolume lama
btrfs subvolume delete @
btrfs subvolume delete @home

# Kembalikan dari snapshot
btrfs subvolume snapshot @clean @
btrfs subvolume snapshot @home_clean @home

# sinkronisasi & reboot
sync
reboot


lubuntu@ubuntu:~$ sudo mkdir -p /mnt/btrfs_root
lubuntu@ubuntu:~$ sudo mount -o subvolid=5 /dev/sda1 /mnt/btrfs_root
lubuntu@ubuntu:~$ cd /mnt/btrfs_root
lubuntu@ubuntu:/mnt/btrfs_root$ sudo btrfs subvolume snapshot -r @ @clean
Create a readonly snapshot of '@' in './@clean'
lubuntu@ubuntu:/mnt/btrfs_root$ sudo btrfs subvolume snapshot -r @home @home_clean
Create a readonly snapshot of '@home' in './@home_clean'
lubuntu@ubuntu:/mnt/btrfs_root$ ls
@  @clean  @home  @home_clean
