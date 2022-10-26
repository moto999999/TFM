output "bastion_public_ip" {
  value = google_compute_instance.instance-bastion.network_interface.0.access_config[0].nat_ip
}

output "worker_ips" {
  value = [
    for instance in google_compute_instance.instance-worker : format("%s: %s",instance.name, instance.network_interface.0.network_ip)
  ]
}

output "control_plane_ips" {
  value = [
    for instance in google_compute_instance.instance-control-plane : format("%s: %s",instance.name, instance.network_interface.0.network_ip)
  ]
}
