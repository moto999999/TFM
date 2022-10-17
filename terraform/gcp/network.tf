resource "google_compute_network" "k8s_network" {
  name = "k8s-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "nodes_subnet" {
  name          = "nodes"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.k8s_network.id
}