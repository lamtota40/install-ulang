ini saya mau restore ya ibarat install ulang lah ini gimana ada yang harus si perbaiki atau di tambah?
semua comand ini akan di jalankan melalui GRML toram
sudo parted /dev/vda
unit b
print
rm 3
mkpart primary btrfs 202375168B 20172924927B
#set 3 boot on
mkpart primary btrfs 20172924928B 38000000000B
mkpart primary linux-swap 38000000001B 100%
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

# copy ke @, set default
sudo btrfs subvolume snapshot /mnt/root/@_backup /mnt/@
sudo btrfs subvolume set-default /mnt/root/@

#cek kembali list & posisi btfrs
sudo btrfs subvolume list /mnt
sudo btrfs subvolume get-default /mnt

# & delete yang lama
sudo btrfs subvolume delete /mnt/root/@_backup
sudo rm /mnt/vda4/btrfs-sda1-backup.img.gz

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
