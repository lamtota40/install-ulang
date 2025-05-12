#!/bin/bash

#buat ram
#buat webserver
sudo systemctl enable autobootgrml.service
sudo mkdir -p /mnt/btrfs_root
sudo mount -o subvolid=5 /dev/sda1 /mnt/btrfs_root
cd /mnt/btrfs_root
sudo wget raw.githubusercontent.com/lamtota40/install-ulang/main/autorun-grml.sh -P /etc/grml/partconf
sudo btrfs subvolume snapshot -r @ @clean
sudo btrfs subvolume snapshot -r @home @home_clean
cd
