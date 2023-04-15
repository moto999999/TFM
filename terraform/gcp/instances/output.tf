output "bastion_instance" {
  value = google_compute_instance.instance-bastion
}

output "mig_worker" {
  value = google_compute_region_instance_group_manager.mig_worker
}

output "mig_control_plane" {
  value = google_compute_region_instance_group_manager.mig_control_plane
}
