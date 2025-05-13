sudo parted /dev/sda
(parted) set 3 swap on
(parted) quit
sudo mkswap /dev/sda3
sudo swapon /dev/sda3
echo '/dev/sda3 none swap sw 0 0' >> /etc/fstab
