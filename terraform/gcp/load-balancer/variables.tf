variable "certificate_private_key" {
  type = string
}

variable "certificate" {
  type = string
}

variable "mig_control_plane" {}

variable "mig_worker" {}

variable "k8s_network" {}

variable "http_ingress_nodeport" {
  type = string
}
