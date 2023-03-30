variable "network_name" {
  type    = string
  default = "k8s-network"
}

variable "subnetwork_name" {
  type = map(any)
  default = {
    bastion       = "bastion"
    control_plane = "control-plane"
    worker        = "worker"
  }
}

variable "ip_cidr_range" {
  type = map(any)
  default = {
    bastion       = "10.0.0.0/24"
    control_plane = "10.0.1.0/24"
    worker        = "10.0.2.0/24"
  }
}