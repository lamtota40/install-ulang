
sudo mount -o subvol=@ /dev/sda1 /mnt
sudo rm -rf /mnt/home
sudo mount -o subvol=@home /dev/sda1 /mnt/tmp
sudo mv /mnt/tmp/* /mnt/home/
sudo umount /mnt/tmp
sudo btrfs subvolume delete /mnt/tmp
sudo cp /etc/fstab /etc/fstab.bak
sudo sed -i '/^[^#]*[[:space:]]\/home[[:space:]]\+btrfs.*subvol=@home/d' /etc/fstab

#mount
sudo mount /dev/sda1 /mnt
#melihat list
sudo btrfs subvolume list /mnt

#backup
sudo btrfs subvolume snapshot -r /mnt/@ /mnt/@_backup
sudo btrfs send /mnt/@_backup | gzip -c > btrfs-root-backup.img.gz

sudo btrfs subvolume snapshot -r /mnt/@home /mnt/@home_backup
sudo btrfs send /mnt/@home_backup | gzip -c > btrfs-home-backup.img.gz

# bersihkan
sudo btrfs subvolume delete /mnt/@_backup
sudo btrfs subvolume delete /mnt/@home_backup
