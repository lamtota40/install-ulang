sudo cat /etc/fstab
#parted /dev/sda
#(parted) mklabel msdos
#(parted) mkpart primary ext4 1048576B 2097151B
#(parted) mkpart primary ext4 2097152B 202375167B

sudo parted /dev/vda
(parted) rm 3
(parted) mkpart primary btrfs 202375168B 20GB
(parted) set 3 boot on
(parted) mkpart primary ext4 20GB 40GB
(parted) mkpart primary linux-swap 40GB 100%
(parted) quit

sudo mkfs.btrfs -f -L rootfs /dev/vda3
sudo mkfs.ext4 -L datafs /dev/vda4
sudo mkswap /dev/vda5
sudo swapon /dev/vda5

# vda4 sebagai tampung file sementara & vda3 root
sudo mkdir /mnt/vda4
sudo mount /dev/vda4 /mnt/vda4
sudo mkdir /mnt/root
sudo mount /dev/vda3 /mnt/root

#dari pengirim
ssh-keygen -f "~/.ssh/known_hosts" -R "147.139.143.79"
sudo rsync -avz --info=progress2 -e ssh /mnt/usb/btrfs-backup.img.gz root@147.139.143.79:/mnt/vda4

#estrak dan di terima btfrs
sudo gunzip -c /mnt/vda4/btrfs-backup.img.gz | sudo btrfs receive /mnt/root

# cek kembali memastikan file/folder @_backup ada
ls /mnt/root

# copy ke @, set default & delete yang lama
sudo btrfs subvolume snapshot /mnt/root/@_backup /mnt/root/@
sudo btrfs subvolume set-default /mnt/root/@
sudo btrfs subvolume delete /mnt/root/@_backup

#cek kembali list & posisi btfrs contoh:ID 257 gen 17 top level 5 path @
sudo btrfs subvolume list /mnt/root
sudo btrfs subvolume get-default /mnt/root

#umount sda3 untuk dipanggil lagi
sudo umount /mnt/root
sudo rm -rf /mnt/root
umount /mnt/vda4

#mount ulang
sudo mkdir /mnt/restore
sudo mount -o subvol=@ /dev/vda3 /mnt/restore

#memastikan file/forder sudah muncul
ls /mnt/restore

# atur FSTAB dan ganti UUID dengan yang baru
sudo cat /mnt/restore/etc/fstab
sudo cp /mnt/restore/etc/fstab /mnt/restore/etc/fstab.bak
sudo blkid
sudo swapon --show=NAME,UUID
sudo nano /mnt/restore/etc/fstab
#contoh swap####UUID=12345678-90ab-cdef-1234-567890abcdef none swap sw 0 0
#flopy##########/dev/fd0        /media/floppy0  auto    rw,user,noauto,exec,utf8 0       0
#efi###########UUID=1C50-31C8  /boot/efi       vfat    umask=0077      0       0
#untuk sda3####UUID=b9ccfd73-d484-430b-a6bf-64f0457bd7d6 /               btrfs   defaults,subvol=@ 0       1
#untuk sda4####UUID=abfaf6a9-ee0f-4069-b41b-d280e8a096ba /data           btrfs   defaults        0       2

#install ulang grub
sudo mount --bind /dev /mnt/restore/dev
sudo mount --bind /proc /mnt/restore/proc
sudo mount --bind /sys /mnt/restore/sys
sudo chroot /mnt/restore
[ -d /sys/firmware/efi ] && echo "UEFI" || echo "BIOS"
#jika uefi##grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ubuntu
grub-install /dev/vda
sudo grub-reboot 0
sudo grub-set-default 'Ubuntu'
mkdir -p /data
update-grub
update-initramfs -u
findmnt --verify --fstab
exit

#delete file backup(optional)
#sudo rm /mnt/vda4/btrfs-sda1-backup.img.gz

#umount
umount /mnt/restore/dev /mnt/restore/proc /mnt/restore/sys
umount /mnt/restore
rm -rf /mnt/restore
rm -rf /mnt/vda4

sync
sudo reboot
