# Megabungkan @home ke @
sudo mount -o subvol=@ /dev/sda1 /mnt
sudo rm -rf /mnt/home
sudo mount -o subvol=@home /dev/sda1 /mnt/tmp
sudo mv /mnt/tmp/* /mnt/home/
sudo umount /mnt/tmp
sudo btrfs subvolume delete /mnt/tmp
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i '/^[^#]*[[:space:]]\/home[[:space:]]\+btrfs.*subvol=@home/d' /etc/fstab
sudo reboot

#mount
sudo mount /dev/sda1 /mnt
#melihat list btrfs
sudo btrfs subvolume list /mnt

#backup
sudo btrfs subvolume snapshot -r /mnt/@ /mnt/@_backup
sudo btrfs send /mnt/@_backup | gzip -c > btrfs-sda1-backup.img.gz

# bersihkan
sudo btrfs subvolume delete /mnt/@_backup
