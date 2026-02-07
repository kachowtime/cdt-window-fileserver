#!/bin/bash

# Exit immediately if a command fails
set -e

# Update the apt package list
echo "Updating apt package lists..."
sudo apt update -y

# Install Ansible, Python3, pip3, and Git
echo "Installing Ansible, Python3, pip3, and Git..."
sudo apt install -y ansible python3 python3-pip git

# Install pywinrm Python module for Windows remote management
echo "Installing pywinrm Python module..."
pip3 install --user pywinrm

# Install Ansible Galaxy collection for Windows modules
echo "Installing Ansible Galaxy collection for Windows modules..."
ansible-galaxy collection install ansible.windows

# Verify installations
echo "Verifying installations..."

# Check Ansible version
echo -n "Ansible version: "
ansible --version | head -n 1

# Check pywinrm installation
python3 -c "import winrm" && echo "pywinrm installed successfully"

# Check Git installation
git --version

# Check Ansible Galaxy version
echo -n "Ansible Galaxy version: "
ansible-galaxy --version

# Final message
echo "Setup complete! Ubuntu is ready with Ansible, Git, Python3, pip3, pywinrm, and Ansible Galaxy."
