bastion=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "bastion:" | sed 's/^.*: //'`
lb_ip=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "lb_ip:" | sed 's/^.*: //'`
control_plane=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "control-plane-.*:" | sed 's/^.*: //' | tr -d ','`
worker=`cd ../terraform/gcp && terraform output | tr -d '"' | grep "worker-.*:" | sed 's/^.*: //' | tr -d ','`

sed -i -e s/replace/$lb_ip/g ../deploy-k8s/roles/deploy-cluster/vars/main.yaml

i=1
for ip_control_plane in $control_plane
do
    sed -i -e s/ip_master_$i/$ip_control_plane/g ../deploy-k8s/inventory
    i=$(($i+1))
done

i=1
for ip_worker in $worker
do
    sed -i -e s/ip_worker_$i/$ip_worker/g ../deploy-k8s/inventory
    i=$(($i+1))
done