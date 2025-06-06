#melihat list
sudo btrfs subvolume list /

#cek kapasitas
sudo btrfs filesystem usage /mnt/root

#perbesar sisi real disk dan hapus sda2
sudo parted /dev/sda
(parted) print               # Lihat struktur partisi
(parted) rm 2                # Hapus sda2
(parted) resizepart 1 100%   # Perbesar sda1 sampai akhir disk
(parted) quit


#perbesar sisi Btfrs(partisi unlocated harus ada)
sudo mkdir /mnt/root
sudo mount /dev/sda1 /mnt/root
sudo btrfs filesystem resize max /mnt/root
sudo umount /mnt/root

#delete btfs
sudo mkdir -p /mnt/btrfs
sudo mount /dev/sda1 /mnt/btrfs
sudo btrfs subvolume list /mnt/btrfs
sudo btrfs subvolume delete /mnt/btrfs/@home
sudo umount /mnt/btrfs


# Megabungkan @home ke @
#!/bin/bash

sudo mount -o subvol=@ /dev/sda1 /mnt
sudo rm -rf /mnt/home
sudo mkdir /mnt/home
sudo mount -o subvol=@home /dev/sda1 /mnt/tmp
sudo mv /mnt/tmp/* /mnt/home/
sudo mv /mnt/tmp/.[!.]* /mnt/home/ || true
sudo umount /mnt/tmp
sudo rm -rf /mnt/tmp
sudo cp /mnt/etc/fstab /mnt/etc/fstab.bak
sudo sed -i '/^[^#]*[[:space:]]\/home[[:space:]]\+btrfs.*subvol=@home/d' /mnt/etc/fstab
#mengembalikan boot ke OS utama
sudo mount --bind /dev /mnt/dev
sudo mount --bind /proc /mnt/proc
sudo mount --bind /sys /mnt/sys
sudo chroot /mnt /bin/bash -c "
sudo grub-reboot 0
sudo grub-set-default 'Ubuntu'
sudo update-grub
"
sudo umount /mnt/dev
sudo umount /mnt/proc
sudo umount /mnt/sys
sudo umount /mnt
sudo reboot
####################################################
# Backup snapshoot btfrs
sudo mkdir -p /mnt/sda1
sudo mount -o subvolid=0 /dev/sda1 /mnt/sda1
sudo btrfs subvolume snapshot -r /mnt/sda1/@ /mnt/sda1/@_backup
sudo btrfs send /mnt/sda1/@_backup | gzip -c > btrfs-sda1-backup.img.gz
#backup tanpa kompresi
sudo btrfs send /mnt/sda1/@_backup > btrfs-sda1-backup.img
#backup ke partisi lain misal /dev/sda2
sudo btrfs send /mnt/sda1/@_backup > /mnt/sda2/btrfs-sda1-backup.img
sudo btrfs send /mnt/sda1/@_backup | gzip -c > /mnt/sda2/btrfs-sda1-backup.img.gz

#umount
sudo umount /mnt/sda1
sudo umount /mnt/sda2

# bersihkan
sudo btrfs subvolume delete /mnt/sda1/@_backup
sudo btrfs balance start /

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
#restore tidak di kompres
sudo btrfs receive /mnt/restore < /root/btrfs-sda1-backup.img

# Rename & delete yang lama
sudo btrfs subvolume snapshot /mnt/@_backup /mnt/@
sudo btrfs subvolume delete /mnt/@_backup

# ganti UUID dengan yang baru
sudo cat /mnt/@/etc/fstab
sudo blkid
sudo nano /mnt/@/etc/fstab


######################################################
sudo mkfs.btrfs -f -L rootfs /dev/vda3
#mount
sudo mkdir /mnt/restore
sudo mount /dev/vda3 /mnt/restore

#melihat list
sudo btrfs subvolume list /
sudo btrfs subvolume set-default 257 /mnt/restore

#edit fstab
sudo blkid /dev/vda3
sudo nano /mnt/restore/etc/fstab

#install ulang grub
sudo mount --bind /dev /mnt/restore/dev
sudo mount --bind /proc /mnt/restore/proc
sudo mount --bind /sys /mnt/restore/sys
sudo chroot /mnt/restore
grub-install /dev/vda
sudo grub-reboot 0
sudo grub-set-default 'Ubuntu'
update-grub
exit
#umount
umount /mnt/root/dev /mnt/root/proc /mnt/root/sys

#################vps
ini saya mau restore ya ibarat install ulang lah ini gimana ada yang harus si perbaiki atau di tambah?
semua comand ini akan di jalankan melalui GRML toram
sudo parted /dev/vda
unit b
print
rm 3
mkpart primary btfrs 202375168B 20172924927B
set 3 boot on
mkpart primary btrfs 20172924928B 36000000000B
mkpart primary linux-swap 36000000001B 100%
quit

sudo mkfs.btrfs -L rootfs /dev/vda3
sudo mkfs.btrfs -L datafs /dev/vda4
sudo mkswap /dev/vda5
sudo swapon /dev/vda5

# vda4 sebagai tampung file sementara & vda3 root
sudo mkdir /mnt/vda4
sudo mount /dev/vda4 /mnt/vda4
sudo mkdir /mnt/root
sudo mount /dev/vda3 /mnt/root

#dari pengirim
sudo rsync -avz -e ssh /mnt/usb/btrfs-sda1-backup.img.gz root@147.139.143.79:/mnt/vda4

#estrak dan di terima btfrs
sudo gunzip -c /mnt/vda4/btrfs-sda1-backup.img.gz | sudo btrfs receive /mnt/root

# Rename, set default & delete yang lama
sudo btrfs subvolume snapshot /mnt/root/@_backup /mnt/@
sudo btrfs subvolume set-default /mnt/root/@
sudo btrfs subvolume delete /mnt/root/@_backup
sudo rm /mnt/vda4/btrfs-sda1-backup.img.gz

#cek kembali list & posisi btfrs
sudo btrfs subvolume list /mnt
sudo btrfs subvolume get-default /mnt

#umount sda3 untuk dipanggil lagi
sudo umount /mnt/root

#mount ulang
sudo mkdir /mnt/restore
sudo mount -o subvol=@ /dev/sda3 /mnt/restore

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
update-grub
update-initramfs -u
findmnt --verify --fstab
exit

# atur FSTAB dan ganti UUID dengan yang baru
sudo cat /mnt/restore/etc/fstab
sudo blkid
sudo nano /mnt/restore/etc/fstab
#contoh swap####UUID=12345678-90ab-cdef-1234-567890abcdef none swap sw 0 0
#flopy##########/dev/fd0        /media/floppy0  auto    rw,user,noauto,exec,utf8 0       0
#efi###########UUID=1C50-31C8  /boot/efi       vfat    umask=0077      0       0
#untuk sda3####UUID=b9ccfd73-d484-430b-a6bf-64f0457bd7d6 /               btrfs   defaults,subvol=@ 0       1
#untuk sda4####UUID=abfaf6a9-ee0f-4069-b41b-d280e8a096ba /data           btrfs   defaults        0       2

#umount
umount /mnt/restore/dev /mnt/restore/proc /mnt/restore/sys
umount /mnt/restore
umount /mnt/root
umount /mnt/vda4

sync
sudo reboot
