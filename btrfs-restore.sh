#!/bin/bash

# Restore snapshot ke kondisi awal

# Mount root dari subvolid=5 (root Btrfs)
mount -o subvolid=5 /dev/sda1 /mnt

# Delete subvolume aktif
btrfs subvolume delete /mnt/@
btrfs subvolume delete /mnt/@home

# Restore dari snapshot bersih
btrfs subvolume snapshot /mnt/btrfs_snapshots/@_clean /mnt/@
btrfs subvolume snapshot /mnt/btrfs_snapshots/@home_clean /mnt/@home

umount /mnt
