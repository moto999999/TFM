resource "google_compute_network" "k8s_network" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "bastion_subnet" {
  name          = var.subnetwork_name["bastion"]
  ip_cidr_range = var.ip_cidr_range["bastion"]
  network       = google_compute_network.k8s_network.id
  region        = var.region
}

resource "google_compute_subnetwork" "control_plane_subnet" {
  name          = var.subnetwork_name["control_plane"]
  ip_cidr_range = var.ip_cidr_range["control_plane"]
  network       = google_compute_network.k8s_network.id
  region        = "europe-west2"
}

resource "google_compute_subnetwork" "worker_subnet" {
  name          = var.subnetwork_name["worker"]
  ip_cidr_range = var.ip_cidr_range["worker"]
  network       = google_compute_network.k8s_network.id
  region        = var.region
}
