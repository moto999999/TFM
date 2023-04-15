variable "tags" {
  type = map(string)
  default = {
    bastion       = "bastion"
    control_plane = "control-plane"
    worker        = "worker"
  }
}

variable "k8s_network_id" {
  type = string
}

variable "http_ingress_nodeport" {
  type = string
}
