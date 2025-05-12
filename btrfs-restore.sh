#!/bin/bash

set -e

# Temukan partisi root aktif
ROOT_DEV=$(findmnt -no SOURCE /)

# Mount root dari subvolid=5 (top-level Btrfs)
mount -o subvolid=5 "$ROOT_DEV" /mnt

# Hapus subvolume lama (abaikan error jika belum ada)
btrfs subvolume delete /mnt/@ || true
btrfs subvolume delete /mnt/@home || true

# Restore dari snapshot
btrfs subvolume snapshot /mnt/btrfs_snapshots/@_clean /mnt/@
btrfs subvolume snapshot /mnt/btrfs_snapshots/@home_clean /mnt/@home

# Set default subvolume ke @
btrfs subvolume set-default $(btrfs subvolume show /mnt/@ | grep 'Subvolume ID' | awk '{print $3}') /mnt

# Unmount kembali
umount /mnt
