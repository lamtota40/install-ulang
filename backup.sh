# Megabungkan @home ke @
sudo mount -o subvol=@ /dev/sda1 /mnt
sudo rm -rf /mnt/home
sudo mkdir /mnt/home
sudo mount -o subvol=@home /dev/sda1 /mnt/tmp
bash
sudo mv /mnt/tmp/* /mnt/home/
sudo mv /mnt/tmp/.[!.]* /mnt/home/
exit
sudo umount /mnt/tmp
sudo btrfs subvolume delete /mnt/tmp
sudo rm -rf /mnt/tmp
sudo cp /mnt/etc/fstab /mnt/etc/fstab.bak
sudo sed -i '/^[^#]*[[:space:]]\/home[[:space:]]\+btrfs.*subvol=@home/d' /mnt/etc/fstab
sudo reboot
####################################################
# Backup snapshoot btfrs
#mount
sudo mount /dev/sda1 /mnt
#melihat list btrfs
sudo btrfs subvolume list /mnt
#backup
sudo btrfs subvolume snapshot -r /mnt/@ /mnt/@_backup
sudo btrfs send /mnt/@_backup | gzip -c > btrfs-sda1-backup.img.gz
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
