resource "google_compute_router" "router" {
  name    = "router-k8s"
  region  = google_compute_subnetwork.worker_subnet.region
  network = google_compute_network.k8s_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
  name                               = "router-k8s-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

resource "google_compute_router" "router_west1" {
  name    = "router-k8s"
  region  = google_compute_subnetwork.control_plane_subnet.region
  network = google_compute_network.k8s_network.id

  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat_west1" {
  name                               = "router-k8s-nat"
  router                             = google_compute_router.router_west1.name
  region                             = "europe-west2"
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}