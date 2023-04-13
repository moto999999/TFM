#!/bin/bash
# Terraform apply
(cd ../terraform/gcp && terraform apply -auto-approve)

# Set ansible variables and inventory from terraform output
./set-ansible-vars-and-inventory.sh

# Copy SSH key to bastion
./copy-ssh-key-to-bastion.sh

# Install ansible.posix on local machine
ansible-galaxy collection install ansible.posix

# Deploy cluster
(cd ../ansible/ && ansible-playbook deploy-cluster.yaml -i inventory)

# Customize cluster
(cd ../ansible/ && ansible-playbook customize-cluster.yaml -i inventory)