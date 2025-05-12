#!/bin/bash

# Pastikan folder snapshot ada
sudo mkdir -p /btrfs_snapshots

sudo wget https://raw.githubusercontent.com/lamtota40/install-ulang/refs/heads/main/btrfs-restore.sh -P /usr/local/bin/
sudo tee /etc/systemd/system/btrfs-restore.service > /dev/null <<EOF
[Unit]
Description=Restore Btrfs snapshot on boot
DefaultDependencies=no
Before=basic.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/btrfs-restore.sh

[Install]
WantedBy=basic.target
EOF

sudo chmod +x /usr/local/bin/btrfs-restore.sh
sudo systemctl daemon-reload
sudo systemctl enable btrfs-restore.service


sudo btrfs subvolume snapshot -r / /btrfs_snapshots/@_clean
sudo btrfs subvolume snapshot -r /home /btrfs_snapshots/@home_clean
