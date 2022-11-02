#! /bin/bash
if [ $# -eq 0 ]; then
    echo "This script requires 1 argument: ./copy-ssh-key-to-bastion.sh [bastion_ip]"
    exit 1
fi

scp -i ../ssh_key/admin ../ssh_key/admin admin@$1:~/.ssh
scp -i ../ssh_key/admin ../ssh_key/admin.pub admin@$1:~/.ssh