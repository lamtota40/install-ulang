
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
sudo reboot-grub "restore snapshot btrfs"

sudo tee /etc/rc.local > /dev/null <<EOF
#!/bin/bash
/usr/local/bin/btrfs-restore.sh
exit 0
EOF

sudo chmod +x /etc/rc.local
sudo systemctl enable rc-local
