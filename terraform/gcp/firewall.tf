resource "google_compute_firewall" "firewall_rule_bastion_ssh" {
  name        = "ssh-bastion-external"
  network     = google_compute_network.k8s_network.id
  description = "Create firewall rule to allow external ssh connections to bastion"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"] # It would be better if only known hosts were allowed
  target_tags   = [var.bastion_tag]
}

resource "google_compute_firewall" "firewall_rule_internal_ssh" {
  name        = "ssh-internal"
  network     = google_compute_network.k8s_network.id
  description = "Create firewall rule to allow internal ssh connections from bastion"

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

resource "google_compute_firewall" "firewall_rule_allow_all_internal_control_plane" {
  name        = "allow-all-internal-control-plane"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for allowing all traffic between control plane nodes"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "ipip"
  }

  source_tags = [var.control_plane_tag]
  target_tags = [var.control_plane_tag]
}

resource "google_compute_firewall" "firewall_rule_allow_all_internal_worker" {
  name        = "allow-all-internal-worker"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for allowing all traffic between control plane nodes"

  allow {
    protocol = "tcp"
  }

  allow {
    protocol = "udp"
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "ipip"
  }

  source_tags = [var.worker_tag]
  target_tags = [var.worker_tag]
}

resource "google_compute_firewall" "firewall_rule_allow_calico" {
  name        = "allow-calico-internal"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for allowing all traffic between control plane nodes"

    allow {
    protocol = "tcp"
    ports    = ["179", "2379", "5473"] # BGP, etcd datastore and Calico networking with Typha enabled
  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "ipip" # Calico networking with IP-in-IP enabled (default)
  }

  source_tags = [var.control_plane_tag, var.worker_tag]
  target_tags = [var.control_plane_tag, var.worker_tag]
}

resource "google_compute_firewall" "firewall_rule_allow_kubelet_api" {
  name        = "allow-kubelet-api"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for allowing kubelet api traffic"

    allow {
    protocol = "tcp"
    ports    = ["10250"] # Kubelet API
  }

  source_tags = [var.control_plane_tag, var.worker_tag]
  target_tags = [var.control_plane_tag, var.worker_tag]
}

resource "google_compute_firewall" "firewall_rule_allow_nodeports" {
  name        = "allow-nodeport-services"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for allowing nodeport services"

    allow {
    protocol = "tcp"
    ports    = ["30000-32767"] # Kubelet API
  }

  source_tags = [var.control_plane_tag, var.worker_tag]
  target_tags = [var.control_plane_tag, var.worker_tag]
}

resource "google_compute_firewall" "firewall_rule_nfs_server" {
  name        = "nfs-server"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for nfs server"

  allow {
    protocol = "tcp"
    ports = [ "111", "2049" ]
  }

  allow {
    protocol = "udp"
    ports = [ "111", "2049" ]
  }

  source_tags = [var.worker_tag, var.bastion_tag]
  target_tags = [var.worker_tag, var.bastion_tag]
}

resource "google_compute_firewall" "firewall_rule_nginx" {
  name        = "ingress-nginx"
  network     = google_compute_network.k8s_network.id
  description = "Creates firewall rule for nfs server"

  allow {
    protocol = "tcp"
    ports = [ "31215" ]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = [var.worker_tag]
}