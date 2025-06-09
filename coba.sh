sudo parted /dev/vda mklabel msdos
sudo parted /dev/vda
mkpart primary btrfs 1MiB 20GB
set 1 boot on
quit

mkfs.btrfs -L rootfs /dev/vda1
mount /dev/vda1 /mnt
wget http://ftp.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.141_all.deb
wget https://ftp.debian.org/debian/pool/main/d/distro-info/distro-info_1.0+deb11u1_amd64.deb
wget https://mirror.pit.teraswitch.com/debian/pool/main/d/distro-info-data/distro-info-data_0.51+deb11u1_all.deb
dpkg -i distro-info*.deb
dpkg -i debootstrap_1.0.141_all.deb
which debootstrap && debootstrap --version
debootstrap bionic /mnt http://archive.ubuntu.com/ubuntu/

rm -rf /mnt/etc/resolv.conf
cp /etc/resolv.conf /mnt/etc/resolv.conf

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
sed -i "s/^127.0.0.1.*/127.0.0.1\tlocalhost $(hostname)/" /etc/hosts
echo "/dev/vda1 / btrfs defaults 0 1" > /etc/fstab
grub-install /dev/vda
update-grub
systemctl enable ssh
exit
umount /mnt/dev/pts
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt
sync

reboot

