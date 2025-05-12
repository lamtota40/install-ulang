#!/bin/bash

# Fungsi untuk membuat snapshot
create_snapshot() {
  echo "Membuat snapshot sistem..."

  # Konfirmasi untuk menghapus snapshot lama
  read -p "Apakah Anda yakin ingin menghapus snapshot lama dan membuat yang baru? (y/n): " confirm
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo "Membatalkan pembuatan snapshot."
    pause
    return 1
  fi

  # Menghapus snapshot lama jika ada
  if [ -e "/btrfs_snapshots/@_clean" ]; then
    echo "Menghapus snapshot lama @clean..."
    sudo btrfs subvolume delete /btrfs_snapshots/@_clean
  fi
  if [ -e "/btrfs_snapshots/@home_clean" ]; then
    echo "Menghapus snapshot lama @home_clean..."
    sudo btrfs subvolume delete /btrfs_snapshots/@home_clean
  fi

  # Membuat snapshot root dan home yang baru
  sudo btrfs subvolume snapshot -r / /btrfs_snapshots/@_clean
  sudo btrfs subvolume snapshot -r /home /btrfs_snapshots/@home_clean

  echo "Snapshot berhasil dibuat."
  pause
}

# Fungsi untuk melakukan restore dari snapshot
restore_system() {
  echo "Melakukan restore sistem..."

  # Tanya pengguna untuk memilih partisi yang ingin di-mount
  read -e -i "/dev/sda1" -p "Masukkan partisi untuk mount (misalnya /dev/sda1): " partition

  if [ ! -e "$partition" ]; then
    echo "Partisi tidak ditemukan: $partition"
    return 1
  fi

  # Mount root dari subvolid=5 (root Btrfs)
  echo "Mounting partisi $partition..."
  sudo mount -o subvolid=5 "$partition" /mnt

  # Hapus subvolume aktif
  sudo btrfs subvolume delete /mnt/@
  sudo btrfs subvolume delete /mnt/@home

  # Restore dari snapshot bersih
  sudo btrfs subvolume snapshot /mnt/btrfs_snapshots/@_clean /mnt/@
  sudo btrfs subvolume snapshot /mnt/btrfs_snapshots/@home_clean /mnt/@home

  # Unmount partisi root
  sudo umount /mnt

  echo "Restore selesai. Sistem akan kembali seperti semula setelah reboot."
  pause
}

# Fungsi pause untuk menunggu input dari pengguna
pause() {
  read -p "Press Enter to return to the menu..."
}

# Menu
while true; do
  clear
  echo "===== Btrfs Snapshot Manager ====="
  echo "1. Restore"
  echo "2. Snapshot"
  echo "0. Exit"
  echo "================================="
  read -p "Pilih opsi: " option

  case $option in
    1)
      restore_system
      ;;
    2)
      create_snapshot
      ;;
    0)
      echo "Keluar..."
      exit 0
      ;;
    *)
      echo "Pilihan tidak valid, coba lagi."
      pause
      ;;
  esac
done
