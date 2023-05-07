output "k8s_network" {
  value = google_compute_network.k8s_network
}

output "bastion_subnet" {
  value = google_compute_subnetwork.bastion_subnet
}

output "control_plane_subnet" {
  value = google_compute_subnetwork.control_plane_subnet
}

output "worker_subnet" {
  value = google_compute_subnetwork.worker_subnet
}
