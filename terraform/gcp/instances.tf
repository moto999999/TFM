resource "google_compute_instance" "instance-bastion" {
  name         = "bastion"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [var.bastion_tag]

  // Rocky linux as image
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb["bastion"]
      type  = var.disk_type["balanced"]
    }
  }

  network_interface {
    network    = google_compute_network.k8s_network.id
    subnetwork = google_compute_subnetwork.nodes_subnet.id
    access_config {
      // Ephemeral public IP
    }
  }

}


resource "google_compute_instance" "instance-control-plane" {
  count = 3

  name         = "control-plane-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [var.control_plane_tag]

  // Rocky linux as image
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb["control_plane"]
      type  = var.disk_type["ssd"]
    }
  }

  // No public IP
  network_interface {
    network    = google_compute_network.k8s_network.id
    subnetwork = google_compute_subnetwork.nodes_subnet.id
  }

}

resource "google_compute_instance" "instance-worker" {
  count = 2

  name         = "worker-${count.index}"
  machine_type = var.machine_type
  zone         = var.zone

  tags = [var.worker_tag]

  // Rocky linux as image
  boot_disk {
    initialize_params {
      image = var.image
      size  = var.disk_size_gb["worker"]
      type  = var.disk_type["ssd"]
    }
  }

  // No public IP
  network_interface {
    network    = google_compute_network.k8s_network.id
    subnetwork = google_compute_subnetwork.nodes_subnet.id
  }

}

resource "google_compute_project_metadata" "metadata" {
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}
