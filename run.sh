#!/bin/bash
#fix

sudo apt install grml-rescueboot zsh -y
sudo mkdir -p /boot/grml
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
    echo "Terdeteksi sistem 64-bit"
    if [ ! -f /boot/grml/grml64-small_2024.02.iso ]; then
    sudo wget https://mirror.kku.ac.th/grml/grml64-small_2024.02.iso -P /boot/grml/
    fi
    GRML_ENTRY='Grml Rescue System (grml64-small_2024.02.iso)'
elif [[ "$ARCH" == "i386" || "$ARCH" == "i686" ]]; then
    echo "Terdeteksi sistem 32-bit"
    if [ ! -f /boot/grml/grml32-small_2024.02.iso ]; then
    sudo wget https://mirror.kku.ac.th/grml/grml32-small_2024.02.iso -P /boot/grml/
    fi
    GRML_ENTRY='Grml Rescue System (grml32-small_2024.02.iso)'
else
    echo "Arsitektur tidak dikenali: $ARCH"
    GRML_ENTRY=''
    exit 1
fi
sudo mkdir -p /etc/grml/partconf
sudo wget raw.githubusercontent.com/lamtota40/install-ulang/main/autorun-grml.sh -P /etc/grml/partconf
sudo bash -c "echo 'CUSTOM_BOOTOPTIONS=\"ssh=pas123 dns=8.8.8.8,8.8.4.4 netscript=raw.githubusercontent.com/lamtota40/install-ulang/main/autorun-grml.sh toram\"' >> /etc/default/grml-rescueboot"
sudo update-grub
sudo grub-reboot "$GRML_ENTRY"

sudo tee /etc/systemd/system/autobootgrml.service > /dev/null <<EOF
[Unit]
Description=Always set boot to GRML
After=local-fs.target

[Service]
Type=oneshot
ExecStart=/usr/sbin/grub-reboot "$GRML_ENTRY"

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl disable autobootgrml.service
