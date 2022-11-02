#! /bin/bash
if [ $# -eq 0 ]; then
    echo "This script requires 1 argument: ./copy-ansible-role-to-bastion.sh [bastion_ip]"
    exit 1
fi

scp -r -i ../ssh_key/admin ../deploy-k8s admin@$1:~/