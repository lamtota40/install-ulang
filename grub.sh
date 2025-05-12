#!/bin/bash

# Pastikan folder snapshot ada & snapshoot
sudo mkdir -p /btrfs_snapshots
sudo btrfs subvolume snapshot -r / /btrfs_snapshots/@_clean
sudo btrfs subvolume snapshot -r /home /btrfs_snapshots/@home_clean

# Membuat boot grub
sudo bash -c 'cat << EOF >> /etc/grub.d/40_custom
menuentry "restore snapshot btrfs" {
    insmod btrfs
    insmod part_gpt
    insmod ext2
    set root="hd0,gpt1"
    linux /boot/vmlinuz-\$(uname -r) root=UUID=\$(blkid -s UUID -o value /dev/sda1) rootflags=subvolid=5 ro quiet
    initrd /boot/initrd.img-\$(uname -r)
}
EOF'

sudo update-grub
sudo grub-reboot "restore snapshot btrfs"

sudo tee /etc/rc.local > /dev/null <<EOF
#!/bin/bash
/usr/local/bin/btrfs-restore.sh
exit 0
EOF

sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local

sudo tee /usr/local/bin/btrfs-restore.sh > /dev/null <<EOF
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
EOF
sudo chmod +x /usr/local/bin/btrfs-restore.sh
