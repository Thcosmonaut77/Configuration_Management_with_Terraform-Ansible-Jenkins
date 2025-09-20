#!/bin/bash
set -e


# Update
sudo apt update -y
sudo apt upgrade -y

# Set password for ${ansible_user} user non-interactively
echo "${ansible_user}:${admin_password}" | sudo chpasswd


# Enable password authentication
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

sudo systemctl restart sshd
sudo systemctl enable ssh

