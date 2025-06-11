#!/bin/bash

parted /dev/vda mklabel msdos ---pretend-input-tty <<EOF
yes
EOF
sleep 3
parted /dev/vda mkpart primary btrfs 1MiB 20GB
parted /dev/vda set 1 boot on

mkfs.btrfs -f -L rootfs /dev/vda1
mount /dev/vda1 /mnt

btrfs subvolume create /mnt/@
umount /mnt
mount -o subvol=@ /dev/vda1 /mnt

wget http://ftp.debian.org/debian/pool/main/d/debootstrap/debootstrap_1.0.141_all.deb
wget https://ftp.debian.org/debian/pool/main/d/distro-info/distro-info_1.0+deb11u1_amd64.deb
wget https://mirror.pit.teraswitch.com/debian/pool/main/d/distro-info-data/distro-info-data_0.51+deb11u1_all.deb
dpkg -i distro-info*.deb
dpkg -i debootstrap_1.0.141_all.deb
debootstrap bionic /mnt http://archive.ubuntu.com/ubuntu/

mount --bind /dev /mnt/dev
mount --bind /dev/pts /mnt/dev/pts
mount --bind /proc /mnt/proc
mount --bind /sys /mnt/sys
cat <<'EOL' | chroot /mnt /bin/bash
mkdir -p /root
apt update
apt install -y locales tzdata
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

export DEBIAN_FRONTEND=noninteractive
echo "grub-pc grub-pc/install_devices multiselect /dev/vda" | debconf-set-selections
apt install -y linux-image-generic grub-pc btrfs-progs openssh-server sudo zsh ifupdown parted

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i '/^#\?PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config

cp /etc/resolv.conf /etc/resolv.conf.bak
rm -rf /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

cat > /etc/network/interfaces <<NETCONF
auto lo
iface lo inet loopback

auto ens3
iface ens3 inet dhcp
NETCONF

useradd -m -s /bin/bash linux
echo "linux:qwerty" | chpasswd
usermod -aG sudo linux
echo "root:qwerty" | chpasswd

echo "ubuntu" > /etc/hostname
sed -i "s/^127.0.0.1.*/127.0.0.1\tlocalhost ubuntu/" /etc/hosts
cp /etc/fstab /etc/fstab.bak
UUID=$(blkid -s UUID -o value /dev/vda1)
echo "UUID=$UUID / btrfs defaults,subvol=@ 0 1" > /etc/fstab
grub-install /dev/vda
update-grub
systemctl enable ssh
EOL

btrfs subvolume set-default /mnt

umount /mnt/dev/pts
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt
rm -rf debootstrap_1.0.141_all.deb distro-info_1.0+deb11u1_amd64.deb distro-info-data_0.51+deb11u1_all.deb
sync
reboot
