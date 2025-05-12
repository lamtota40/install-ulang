sudo nano /etc/grub.d/40_custom
menuentry "Restore Snapshot (Btrfs Clean Boot)" {
    insmod btrfs
    insmod part_gpt
    insmod ext2
    set root='hd0,gpt1'  # Ganti sesuai lokasi partisi kamu
    linux /boot/vmlinuz-$(uname -r) root=UUID=$(blkid -s UUID -o value /dev/sda1) rootflags=subvolid=5 ro quiet
    initrd /boot/initrd.img-$(uname -r)
}
sudo update-grub
