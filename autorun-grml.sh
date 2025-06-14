#!/bin/bash

sudo mkdir -p /mnt/res
sudo mount -o subvolid=5 /dev/vda1 /mnt/res
sudo btrfs subvolume list /mnt/res
sudo btrfs subvolume delete /mnt/res/@
sudo btrfs subvolume snapshot /mnt/res/@_clean /mnt/res/@
ID=$(sudo btrfs subvolume show /mnt/res 2>&1 | awk -F': *' '/Subvolume ID:/ {print $2}' | xargs)
sudo btrfs subvolume set-default "$ID" /mnt/res
sudo umount /mnt/res
sudo rm -rf /mnt/res
sync
sudo reboot
