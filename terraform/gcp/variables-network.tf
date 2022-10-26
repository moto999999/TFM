variable "network_name" {
  type    = string
  default = "k8s-network"
}

variable "subnetwork_name" {
  type    = string
  default = "nodes"
}

variable "ip_cidr_range" {
  type    = string
  default = "10.0.0.0/24"
}
