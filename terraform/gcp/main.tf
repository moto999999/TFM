terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }

  backend "gcs" {
    bucket = "tfm-uc3m-392409"
    prefix = "terraform/state"
  }
}

locals {
  # Network
  k8s_network = module.vpc.k8s_network
  subnets = {
    bastion       = module.vpc.bastion_subnet
    control_plane = module.vpc.control_plane_subnet
    worker        = module.vpc.worker_subnet
  }
  k8s_lb = module.lb.k8s_lb

  # Instances
  mig_control_plane = module.instances.mig_control_plane
  mig_worker        = module.instances.mig_worker

  # Disk
  nfs_disk = module.disks.nfs_disk
}

# VPC module
module "vpc" {
  source = "./modules/vpc"

  # Network configuration
  network_name    = var.network_name
  subnetwork_name = var.subnetwork_name
  ip_cidr_range   = var.ip_cidr_range

  region = var.region
}

# Firewall module
module "firewall" {
  source = "./modules/firewall"
  tags   = var.instance_tags

  # Network
  k8s_network_id        = local.k8s_network.id
  http_ingress_nodeport = var.http_ingress_nodeport
}

# Load balancer module
module "lb" {
  source = "./modules/load-balancer"

  # Certificates
  certificate_private_key = var.certificate_private_key
  certificate             = var.certificate

  # Managed Instance Groups
  mig_control_plane = local.mig_control_plane
  mig_worker        = local.mig_worker

  # Network
  k8s_network           = local.k8s_network
  http_ingress_nodeport = var.http_ingress_nodeport

  # DNS name
  dns_name = var.dns_name
}

# Instances module
module "instances" {
  source = "./modules/instances"

  # Machine configuration
  machine_type     = var.machine_type
  zone             = var.zone
  instance_tags    = var.instance_tags
  image            = var.image
  ssh_user         = var.ssh_user
  ssh_pub_key_file = var.ssh_pub_key_file

  # Network configuration
  network               = local.k8s_network
  subnetworks           = local.subnets
  http_ingress_nodeport = var.http_ingress_nodeport

  # Disk configuration
  disk_size_gb = var.disk_size_gb
  disk_type    = var.disk_type
  nfs_disk     = local.nfs_disk

  # Kubernetes configuration
  number_control_planes = var.number_control_planes
  number_workers        = var.number_workers
  region                = var.region
}

# Disk management module
module "disks" {
  source = "./modules/disks"

  # Disk configuration
  disk_type    = var.disk_type
  disk_size_gb = var.disk_size_nfs

  # Zone configuration
  zone   = var.zone
  region = var.region
}

# DNS module
module "dns" {
  source = "./modules/dns"

  # Load Balancer instance
  k8s_lb = local.k8s_lb

  # DNS names
  dns_name  = var.dns_name
  dns_names = var.dns_names

  # Zone configuration
  zone   = var.zone
  region = var.region
}
