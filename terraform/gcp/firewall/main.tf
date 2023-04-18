resource "google_compute_firewall" "firewall_rule_bastion_ssh" {
  name        = "ssh-bastion-external"
  network     = var.k8s_network_id
  description = "Create firewall rule to allow external ssh connections to the bastion instance"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.tags["bastion"]]
}

resource "google_compute_firewall" "firewall_rule_internal_ssh" {
  name        = "ssh-internal"
  network     = var.k8s_network_id
  description = "Create firewall rule to allow internal ssh connections from the bastion instance"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_tags = [var.tags["bastion"]]
  target_tags = [var.tags["control_plane"], var.tags["worker"]]
}

resource "google_compute_firewall" "firewall_rule_api_server" {
  name        = "kubernetes-api-server"
  network     = var.k8s_network_id
  description = "Create firewall rule to allow access to the Kubernetes API server"

  allow {
    protocol = "tcp"
    ports    = ["6443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.tags["control_plane"]]
}

resource "google_compute_firewall" "firewall_rule_allow_all_internal_control_plane" {
  name        = "allow-all-internal-control-plane"
  network     = var.k8s_network_id
  description = "Creates firewall rule to allow all traffic between Kubernetes control plane nodes"

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

  source_tags = [var.tags["control_plane"]]
  target_tags = [var.tags["control_plane"]]
}

resource "google_compute_firewall" "firewall_rule_allow_all_internal_worker" {
  name        = "allow-all-internal-worker"
  network     = var.k8s_network_id
  description = "Creates firewall rule  to allow all traffic between Kubernetes worker nodes"

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

  source_tags = [var.tags["worker"]]
  target_tags = [var.tags["worker"]]
}

resource "google_compute_firewall" "firewall_rule_allow_calico" {
  name        = "allow-calico-internal"
  network     = var.k8s_network_id
  description = "Creates firewall rule to allow Calico networking traffic between control plane and worker nodes"

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

  source_tags = [var.tags["control_plane"], var.tags["worker"]]
  target_tags = [var.tags["control_plane"], var.tags["worker"]]
}

resource "google_compute_firewall" "firewall_rule_allow_kubelet_api" {
  name        = "allow-kubelet-api"
  network     = var.k8s_network_id
  description = "Creates firewall rule to allow traffic to the kubelet API from control plane and worker nodes"

  allow {
    protocol = "tcp"
    ports    = ["10250"] # Kubelet API
  }

  source_tags = [var.tags["control_plane"], var.tags["worker"]]
  target_tags = [var.tags["control_plane"], var.tags["worker"]]
}

resource "google_compute_firewall" "firewall_rule_allow_nodeports" {
  name        = "allow-nodeport-services"
  network     = var.k8s_network_id
  description = "Creates firewall rule to allow traffic to nodeport services from control plane and worker nodes"

  allow {
    protocol = "tcp"
    ports    = ["30000-32767"] # Kubelet API
  }

  source_tags = [var.tags["control_plane"], var.tags["worker"]]
  target_tags = [var.tags["control_plane"], var.tags["worker"]]
}

resource "google_compute_firewall" "firewall_rule_nfs_server" {
  name        = "nfs-server"
  network     = var.k8s_network_id
  description = "Creates firewall rule to allow access to the NFS server from worker and bastion instances"

  allow {
    protocol = "tcp"
    ports    = ["111", "2049"]
  }

  allow {
    protocol = "udp"
    ports    = ["111", "2049"]
  }

  source_tags = [var.tags["worker"], var.tags["bastion"]]
  target_tags = [var.tags["worker"], var.tags["bastion"]]
}

resource "google_compute_firewall" "firewall_rule_nginx" {
  name        = "ingress-nginx"
  network     = var.k8s_network_id
  description = "Creates firewall rule to allow traffic to the ingress nginx nodeport service from external sources"

  allow {
    protocol = "tcp"
    ports    = [var.http_ingress_nodeport]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.tags["worker"]]
}
