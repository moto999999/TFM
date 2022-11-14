#!/bin/bash
cd ../terraform/gcp
terraform apply -auto-approve

cd ../../utilities

echo "Waiting 25 seconds to wait until ansible is installed in bastion"
sleep 25

./set-ansible-vars-and-inventory.sh
./copy-ssh-key-to-bastion.sh
./copy-ansible-role-to-bastion.sh

bastion=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "bastion:" | sed 's/^.*: //'`
ssh -i ../ssh_key/admin admin@$bastion "cd deploy-k8s/ && ansible-playbook deploy-cluster.yaml -i inventory"
