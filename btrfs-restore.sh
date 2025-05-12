#!/bin/bash

set -e

# Mount root Btrfs top-level
mount -o subvolid=5,defaults $(findmnt -no SOURCE /) /mnt

# Hapus subvolume lama
btrfs subvolume delete /mnt/@ || true
btrfs subvolume delete /mnt/@home || true

# Restore snapshot
btrfs subvolume snapshot /mnt/btrfs_snapshots/@_clean /mnt/@
btrfs subvolume snapshot /mnt/btrfs_snapshots/@home_clean /mnt/@home

# Set default subvolume ke @
btrfs subvolume set-default $(btrfs subvolume show /mnt/@ | grep 'Subvolume ID' | awk '{print $3}') /mnt

# Unmount
umount /mnt
