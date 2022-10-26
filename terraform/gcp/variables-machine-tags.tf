variable "bastion_tag" {
  type    = string
  default = "bastion"
}

variable "control_plane_tag" {
  type    = string
  default = "control-plane"
}

variable "worker_tag" {
  type    = string
  default = "worker"
}
