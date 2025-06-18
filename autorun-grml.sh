#!/bin/bash

sudo mkdir -p /mnt/res
sudo mount -o subvolid=5 /dev/vda1 /mnt/res
sudo btrfs subvolume list /mnt/res
sudo btrfs subvolume delete /mnt/res/@
sudo btrfs subvolume snapshot /mnt/res/@_last /mnt/res/@
ID=$(btrfs subvolume show /mnt/res 2>&1 | awk -F': *' '/Subvolume ID:/ {print $2}' | xargs)
btrfs subvolume set-default "$ID" /mnt/res
sudo umount /mnt/res
sudo rm -rf /mnt/res
sudo rm -rf autorun-grml.sh
sync
sudo reboot
