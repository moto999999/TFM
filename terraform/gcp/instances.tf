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

  attached_disk {
    source = google_compute_disk.nfs_disk.self_link
    mode   = "READ_WRITE"
  }

  metadata_startup_script = "sudo dnf install ansible-core nano -y && printf 'Host *\n\tUser admin\n\tIdentityFile ~/.ssh/admin\n' > /home/admin/.ssh/config"
}

# instance template for control plane
resource "google_compute_instance_template" "control_plane" {
  name         = "control-plane-template"
  machine_type = var.machine_type

  tags = [var.control_plane_tag]

  // Rocky linux as image
  disk {
    source_image = var.image
    disk_size_gb = var.disk_size_gb["control_plane"]
    disk_type    = var.disk_type["ssd"]
    boot         = true
  }

  // No public IP
  network_interface {
    network    = google_compute_network.k8s_network.id
    subnetwork = google_compute_subnetwork.nodes_subnet.id
  }

  metadata_startup_script = "sudo dnf install ansible-core nano -y"
}

# MIG for control planes
resource "google_compute_region_instance_group_manager" "mig_control_plane" {
  name   = "k8s-control-plane-mig"
  region = var.region
  version {
    instance_template = google_compute_instance_template.control_plane.id
    name              = "control-plane"
  }
  base_instance_name = "control-plane"
  target_size        = var.number_control_planes

  named_port {
    name = "api-server"
    port = 6443
  }

  wait_for_instances = true
}

# instance template for worker
resource "google_compute_instance_template" "worker" {
  name         = "worker-template"
  machine_type = var.machine_type

  tags = [var.worker_tag]

  // Rocky linux as image
  disk {
    source_image = var.image
    disk_size_gb = var.disk_size_gb["worker"]
    disk_type    = var.disk_type["ssd"]
    boot         = true
  }

  // No public IP
  network_interface {
    network    = google_compute_network.k8s_network.id
    subnetwork = google_compute_subnetwork.nodes_subnet.id
  }

  metadata_startup_script = "sudo dnf install ansible-core nano -y"
}

# MIG for workers
resource "google_compute_region_instance_group_manager" "mig_worker" {
  name   = "k8s-worker-mig"
  region = var.region
  version {
    instance_template = google_compute_instance_template.worker.id
    name              = "worker"
  }
  base_instance_name = "worker"
  target_size        = var.number_workers

  named_port {
    name = "nginx"
    port = 31215
  }

  wait_for_instances = true
}

resource "google_compute_project_metadata" "metadata" {
  metadata = {
    ssh-keys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
}
