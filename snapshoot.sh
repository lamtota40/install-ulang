sudo mkdir -p /btrfs_snapshots
sudo btrfs subvolume snapshot -r / /btrfs_snapshots/@_clean
sudo btrfs subvolume snapshot -r /home /btrfs_snapshots/@home_clean
