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

mkdir -p /root
chmod 700 /root
chown root:root /root

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
export DEBIAN_FRONTEND=noninteractive
# Hostname
echo "ubuntu" > /etc/hostname
sed -i 's/^127\.0\.0\.1[[:space:]]\+localhost$/127.0.0.1\tubuntu\n127.0.0.1\tlocalhost/' /etc/hosts
sudo hostnamectl set-hostname ubuntu

cat > /etc/apt/sources.list <<'EOF'
deb http://archive.ubuntu.com/ubuntu bionic main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu bionic-backports main restricted universe multiverse
deb http://security.ubuntu.com/ubuntu bionic-security main restricted universe multiverse
EOF

apt update

# Instal paket utama
apt install -y locales tzdata
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8
echo 'LANG=en_US.UTF-8' > /etc/environment
export LANG=en_US.UTF-8

ln -sf /usr/share/zoneinfo/Asia/Jakarta /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# Paket penting untuk boot dan sistem
echo "grub-pc grub-pc/install_devices multiselect /dev/vda" | debconf-set-selections
apt install -y linux-image-generic systemd-sysv software-properties-common grub-pc net-tools telnet btrfs-progs openssh-server sudo nano zsh bash-completion ifupdown rsync jq lsof curl unzip zip initramfs-tools
apt install -y parted e2fsprogs dosfstools rsyslog

# ✅ Tambahan agar passwd/login root tidak error
apt install -y shadow login passwd libpam-modules libpam-runtime libpam-modules-bin libpam0g
usermod -s /bin/bash root
cp /etc/skel/.bashrc /root/
cp /etc/skel/.profile /root/

# SSH config
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i '/^#\?PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config

# DNS config
cp /etc/resolv.conf /etc/resolv.conf.bak
rm -rf /etc/resolv.conf
echo "nameserver 8.8.8.8" > /etc/resolv.conf
echo "nameserver 1.1.1.1" >> /etc/resolv.conf

# Jaringan
cat > /etc/network/interfaces <<NETCONF
auto lo
iface lo inet loopback

auto ens3
iface ens3 inet dhcp
NETCONF

# User & password
useradd -m -s /bin/bash linux
echo "linux:Ch1ndy12$" | chpasswd
usermod -aG sudo linux
echo "root:Ch1ndy12$" | chpasswd

cp /etc/fstab /etc/fstab.bak
UUID=$(blkid -s UUID -o value /dev/vda1)
echo "UUID=$UUID / btrfs defaults,subvol=@ 0 1" > /etc/fstab
update-initramfs -u
grub-install /dev/vda
update-grub
systemctl enable ssh
EOL

# Set default subvolume ke ID dari @
ID=$(btrfs subvolume show / 2>&1 | awk -F': *' '/Subvolume ID:/ {print $2}' | xargs)
btrfs subvolume set-default "$ID" /mnt

# Unmount dan bereskan
umount /mnt/dev/pts
umount /mnt/dev
umount /mnt/proc
umount /mnt/sys
umount /mnt
rm -rf debootstrap_1.0.141_all.deb distro-info_1.0+deb11u1_amd64.deb distro-info-data_0.51+deb11u1_all.deb
sync
read -p "Isntalasi selesai,tekan [ENTER] untuk reboot"
reboot
