bastion=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "bastion_public_ip:" | sed 's/^.*: //'`

scp -r -i ../ssh_key/admin ../deploy-k8s admin@$bastion:~/
ssh -i ../ssh_key/admin admin@$bastion ansible-galaxy collection install ansible.posix