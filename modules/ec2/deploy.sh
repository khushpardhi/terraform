#!/bin/bash -e

echo "Updating the system..."
apt-get update -y

echo "Installing dependencies..."
apt install -y software-properties-common python3-pip

echo "Adding Ansible PPA..."
add-apt-repository ppa:ansible/ansible -y

echo "Updating package list again..."
apt-get update -y

echo "Installing Ansible..."
apt install -y ansible

echo "Verifying Ansible installation..."
ansible --version

mkdir -p /workspace/repo

cd /workspace/repo

echo "Cloning the repository..."
git clone https://github.com/khushpardhi/wanderlust.git

# cat /workspace/repo
ls /workspace/repo


cd /workspace/repo/wanderlust/ansible

ansible-playbook main.yml
