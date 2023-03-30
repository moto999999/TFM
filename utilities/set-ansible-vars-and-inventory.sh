git checkout origin/master ../deploy-k8s/inventory ../deploy-k8s/roles/deploy-cluster/vars/main.yaml
rm -rf ~/.ssh/known_hosts

ip_bastion=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "bastion_public_ip:" | sed 's/^.*: //'`
ip_bastion_internal=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "bastion_private_ip:" | sed 's/^.*: //'`
ip_lb=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "lb_ip:" | sed 's/^.*: //'`
ips_control_plane=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "control-plane-.*:" | sed 's/^.*: //' | tr -d ','`
ips_worker=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "worker-.*:" | sed 's/^.*: //' | tr -d ','`

sed -i -e s/ip_lb/$ip_lb/g ../deploy-k8s/roles/deploy-cluster/vars/main.yaml
sed -i -e s/ip_bastion_internal/$ip_bastion_internal/g ../deploy-k8s/roles/deploy-cluster/vars/main.yaml

sed -i -e s/ip_bastion/$ip_bastion/g ../deploy-k8s/inventory

i=1
for ip_control_plane in $ips_control_plane
do
    sed -i -e s/ip_master_$i/$ip_control_plane/g ../deploy-k8s/inventory
    i=$(($i+1))
done

i=1
for ip_worker in $ips_worker
do
    sed -i -e s/ip_worker_$i/$ip_worker/g ../deploy-k8s/inventory
    i=$(($i+1))
done