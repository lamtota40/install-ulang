#!/bin/bash
set -e

# Temukan partisi root aktif tanpa [subvol]
ROOT_DEV=$(findmnt -no SOURCE / | sed 's/\[.*\]//')

# Mount root Btrfs top-level
mount -o subvolid=5 "$ROOT_DEV" /mnt

# Cek apakah direktori btrfs_snapshots ada dan berisi snapshot yang diperlukan
if [ ! -d /btrfs_snapshots ]; then
  echo "Direktori /btrfs_snapshots tidak ditemukan!"
  exit 1
fi

if [ ! -d /btrfs_snapshots/@_clean ]; then
  echo "Snapshot @_clean tidak ditemukan!"
  exit 1
fi

if [ ! -d /btrfs_snapshots/@home_clean ]; then
  echo "Snapshot @home_clean tidak ditemukan!"
  exit 1
fi

# Hapus subvolume lama jika ada
btrfs subvolume delete /mnt/@ || true
btrfs subvolume delete /mnt/@home || true

# Restore snapshot
btrfs subvolume snapshot /mnt/btrfs_snapshots/@_clean /mnt/@
btrfs subvolume snapshot /mnt/btrfs_snapshots/@home_clean /mnt/@home

# Set default subvolume ke @
btrfs subvolume set-default "$(btrfs subvolume show /mnt/@ | grep 'Subvolume ID' | awk '{print $3}')" /mnt

# Unmount
umount /mnt
