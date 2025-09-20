#!/bin/bash
set -e

# Update and upgrade system
sudo apt update -y
sudo apt upgrade -y

echo "===== Installing java ====="
sudo apt-get install -y openjdk-21-jdk

echo "===== Adding Jenkins repository and GPG key ====="
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
    /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
    https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
    /etc/apt/sources.list.d/jenkins.list > /dev/null

echo "===== Updating package list and installing Jenkins ====="
sudo apt-get update -y
sudo apt-get install -y jenkins


echo "===== Enabling and starting Jenkins ====="
sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "===== Jenkins installation complete ====="
echo "Initial Jenkins admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

# Install Ansible
sudo apt install -y ansible sshpass

# Set password for ${ansible_user} user
echo "${ansible_user}:${admin_password}" | sudo chpasswd

# Enable password authentication
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config.d/60-cloudimg-settings.conf

sudo systemctl restart sshd
sudo systemctl enable ssh

# Generate SSH key for ansible (non-interactive)
sudo -u ${ansible_user} ssh-keygen -t rsa -b 4096 -f /home/${ansible_user}/.ssh/id_rsa -N ""

# Ensure proper ownership
chown ${ansible_user}:${ansible_user} /home/${ansible_user}/.ssh/id_rsa*
chmod 600 /home/${ansible_user}/.ssh/id_rsa
chmod 644 /home/${ansible_user}/.ssh/id_rsa.pub

# Create Ansible config
sudo -u ${ansible_user} mkdir -p /home/${ansible_user}/ansible

cat <<EOF | sudo -u ${ansible_user} tee /home/${ansible_user}/ansible/ansible.cfg > /dev/null
[defaults]
inventory = /home/${ansible_user}/ansible/hosts
remote_user = ${ansible_user}
host_key_checking = False
retry_files_enabled = False
EOF


# Create inventory file from passed IPs
{
    echo "[slaves]"
    for ip in $(echo ${slave_ips} | tr ',' ' '); do
        echo "$ip ansible_user=${ansible_user} ansible_ssh_private_key_file=/home/${ansible_user}/.ssh/id_rsa"
    done
} | sudo -u ${ansible_user} tee /home/${ansible_user}/ansible/hosts > /dev/null

# Create nginx.yaml

cat <<EOF | sudo -u ${ansible_user} tee /home/${ansible_user}/ansible/nginx.yaml > /dev/null
---
- name: set up webserver
  hosts: slaves
  become: true
  tasks:
    - name: ensure nginx is at the latest version
      apt:
        name: nginx
        state: latest
        update_cache: yes

    - name: start nginx
      service:
        name: nginx
        state: started
        enabled: yes
EOF

# Create update.yaml

cat <<EOF | sudo -u ${ansible_user} tee /home/${ansible_user}/ansible/update.yaml > /dev/null
---
- hosts: servers
  become: true
  become_user: root
  tasks:
    - name: Update apt repo and cache on all Debian/Ubuntu boxes
      apt: update_cache=yes force_apt_get=yes cache_valid_time=3600

    - name: Upgrade all packages on servers
      apt: upgrade=dist force_apt_get=yes

    - name: Check if a reboot is needed on all servers
      register: reboot_required_file
      stat: path=/var/run/reboot-required get_md5=no

    - name: Reboot the box if kernel updated
      reboot:
        msg: "Reboot initiated by Ansible for kernel updates"
        connect_timeout: 5
        reboot_timeout: 300
        pre_reboot_delay: 0
        post_reboot_delay: 30
        test_command: uptime
      when: reboot_required_file.stat.exists
EOF      

 # Make sure ${ansible_user} owns ansible directory
chown -R ${ansible_user}:${ansible_user} /home/${ansible_user}/ansible           


