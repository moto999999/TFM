######### bastion #########
output "bastion_public_ip" {
  value = format("%s_public_ip: %s", module.instances.bastion_instance.name, module.instances.bastion_instance.network_interface.0.access_config[0].nat_ip)
}

output "bastion_private_ip" {
  value = format("%s_private_ip: %s", module.instances.bastion_instance.name, module.instances.bastion_instance.network_interface.0.network_ip)
}

######### control plane #########
data "google_compute_region_instance_group" "mig_data_control_plane" {
  name   = module.instances.mig_control_plane.name
  region = "europe-west1"
  depends_on = [
    module.instances.mig_control_plane
  ]
}

data "google_compute_instance" "instance_data_control_plane" {
  count     = var.number_control_planes
  self_link = data.google_compute_region_instance_group.mig_data_control_plane.instances[count.index].instance
  depends_on = [
    data.google_compute_region_instance_group.mig_data_control_plane
  ]
}

output "control_plane_ips" {
  value = [
    for instance in data.google_compute_instance.instance_data_control_plane :
    format("%s: %s", instance.name, instance.network_interface.0.network_ip)
  ]
  depends_on = [
    data.google_compute_instance.instance_data_control_plane
  ]
}

######### worker #########
data "google_compute_region_instance_group" "mig_data_worker" {
  name   = module.instances.mig_worker.name
  region = var.region
  depends_on = [
    module.instances.mig_worker
  ]
}

data "google_compute_instance" "instance_data_worker" {
  count     = var.number_workers
  self_link = data.google_compute_region_instance_group.mig_data_worker.instances[count.index].instance
  depends_on = [
    data.google_compute_region_instance_group.mig_data_worker
  ]
}

output "worker_ips" {
  value = [
    for instance in data.google_compute_instance.instance_data_worker :
    format("%s: %s", instance.name, instance.network_interface.0.network_ip)
  ]
  depends_on = [
    data.google_compute_instance.instance_data_worker
  ]
}

output "lb_ip" {
  value = format("%s: %s", "lb_ip", module.lb.k8s_lb.address)
}
