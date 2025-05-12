#!/bin/bash

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

sudo systemctl daemon-reload
sudo systemctl enable btrfs-restore.service
