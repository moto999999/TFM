bastion=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "bastion:" | sed 's/^.*: //'`

scp -r -i ../ssh_key/admin ../deploy-k8s admin@$bastion:~/