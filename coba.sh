sudo parted /dev/vda mklabel msdos
sudo parted /dev/vda
mkpart primary btrfs 1MiB 20GB
set 1 boot on
quit

mkfs.btrfs /dev/vda1
mount /dev/vda1 /mnt
debootstrap bionic /mnt http://archive.ubuntu.com/ubuntu/

mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
chroot /mnt /bin/bash
apt update
apt install linux-image-generic grub-pc btrfs-progs openssh-server sudo zsh -y

# Set timezone
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
dpkg-reconfigure tzdata

# Set locale
apt install locales
dpkg-reconfigure locales

echo "ubuntu" > /etc/hostname
echo "/dev/sda3 / btrfs defaults 0 1" > /etc/fstab
grub-install /dev/vda
update-grub
systemctl enable ssh
exit
umount /mnt/dev/pts
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt
reboot

