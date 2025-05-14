# Megabungkan @home ke @
#!/bin/bash

sudo mount -o subvol=@ /dev/sda1 /mnt
sudo rm -rf /mnt/home
sudo mkdir /mnt/home
sudo mount -o subvol=@home /dev/sda1 /mnt/tmp
sudo mv /mnt/tmp/* /mnt/home/
sudo mv /mnt/tmp/.[!.]* /mnt/home/ || true
sudo umount /mnt/tmp
sudo rm -rf /mnt/tmp
sudo btrfs subvolume delete /mnt/@home
sudo cp /mnt/etc/fstab /mnt/etc/fstab.bak
sudo sed -i '/^[^#]*[[:space:]]\/home[[:space:]]\+btrfs.*subvol=@home/d' /mnt/etc/fstab
#mengembalikan boot ke OS utama
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt /bin/bash -c "
sudo grub-reboot 0
sudo grub-set-default 'Ubuntu'
sudo update-grub
"
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys
sudo umount /mnt
sudo reboot
####################################################
#melihat list btrfs
sudo btrfs subvolume list /mnt/sda1


# Backup snapshoot btfrs
#mount
sudo mkdir /mnt/sda1
sudo mount /dev/sda1 /mnt/sda1
sudo btrfs subvolume snapshot -r /mnt/sda1/@ /mnt/sda1/@_backup
sudo btrfs send /mnt/sda1/@_backup | gzip -c > btrfs-sda1-backup.img.gz
#backup tanpa kompresi
sudo btrfs send /mnt/sda1/@_backup > btrfs-sda1-backup.img

#backup ke partisi lain misal /dev/sda2
sudo mkdir /mnt/sda2
sudo mount /dev/sda2 /mnt/sda2
sudo btrfs subvolume snapshot -r / /mnt/sda2/@_backup
sudo btrfs send /mnt/sda1/@_backup > /mnt/sda2/btrfs-sda1-backup.img
sudo btrfs send /mnt/sda1/@_backup | gzip -c > /mnt/sda2/btrfs-sda1-backup.img.gz

#umount
sudo umount /mnt/sda1
sudo umount /mnt/sda2


# bersihkan
sudo btrfs subvolume delete /mnt/@_backup
# catat size semua partisi dalam byte agar presisi
sudo parted /dev/sda unit B print
sudo reboot
####################################################
# Membuat partisi & Restore dari GRML toram (Live CD)
sudo parted /dev/sda
(parted) unit B
(parted) print
(parted) mklabel msdos (yes)
(parted) mkpart primary btrfs 1048576B 14400094207B
(parted) set 1 boot on
(parted) mkpart primary btrfs 14400094208B 19971178495B
(parted) quit

#format partisi tipe btrfs
sudo mkfs.btrfs -f /dev/sda1
sudo mkfs.btrfs -f /dev/sda2

#mount dan restore
sudo mount /dev/sda1 /mnt
sudo gunzip -c btrfs-sda1-backup.img.gz | sudo btrfs receive /mnt

# Rename & delete yang lama
sudo btrfs subvolume snapshot /mnt/@_backup /mnt/@
sudo btrfs subvolume delete /mnt/@_backup

# ganti UUID dengan yang baru
sudo cat /mnt/@/etc/fstab
sudo blkid
sudo nano /mnt/@/etc/fstab
