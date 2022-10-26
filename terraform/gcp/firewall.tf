resource "google_compute_firewall" "firewall_rule_bastion_ssh" {
  name        = "ssh-bastion-external"
  network     = google_compute_network.k8s_network.id
  description = "Create firewall rule to allow external ssh connections to bastion"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # It would be better if only known hosts were allowed
}

resource "google_compute_firewall" "firewall_rule_bastion_inside" {
  name        = "ssh-inside-network-bastion"
  network     = google_compute_network.k8s_network.id
  description = "Create firewall rule to allow ssh connections from bastion to rest of the cluster"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_tags = [var.bastion_tag]
  target_tags = [var.control_plane_tag, var.worker_tag]
}

resource "google_compute_firewall" "firewall_rule_api_server" {
  name        = "kubernetes-api-server"
  network     = google_compute_network.k8s_network.id
  description = "Create firewall rule for api server"

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.control_plane_tag]
}

resource "google_compute_firewall" "firewall_rule_etcd" {
  name        = "etcd-server-client-api"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for etcd server"

  allow {
    protocol = "tcp"
    ports    = ["2379-2380"]
  }

  source_tags = [var.control_plane_tag, var.worker_tag]
  target_tags = [var.control_plane_tag]
}

resource "google_compute_firewall" "firewall_rule_kubelet_api" {
  name        = "kubelet-api"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for kubelet api"

  allow {
    protocol = "tcp"
    ports    = ["10250"]
  }

  source_tags = [var.control_plane_tag, var.worker_tag]
  target_tags = [var.control_plane_tag, var.worker_tag]
}

resource "google_compute_firewall" "firewall_rule_kube_scheduler" {
  name        = "kube-scheduler"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for kube scheduler"

  allow {
    protocol = "tcp"
    ports    = ["10259"]
  }

  source_tags = [var.control_plane_tag]
  target_tags = [var.control_plane_tag]
}

resource "google_compute_firewall" "firewall_rule_kube_controller_manager" {
  name        = "kube-controller-manager"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for kube controller manager"

  allow {
    protocol = "tcp"
    ports    = ["10257"]
  }

  source_tags = [var.control_plane_tag]
  target_tags = [var.control_plane_tag]
}

resource "google_compute_firewall" "firewall_rule_nodeport_services" {
  name        = "nodeport-services"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for NodePort Services"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"]
  }

  source_tags = [var.worker_tag]
  target_tags = [var.control_plane_tag, var.worker_tag]
}
