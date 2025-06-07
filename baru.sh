#!/bin/bash

sudo apt update
sudo apt upgrade -y
sudo apt install zsh openssh-server -y
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i '/^#\?PermitRootLogin/c\PermitRootLogin yes' /etc/ssh/sshd_config
sudo systemctl restart ssh
