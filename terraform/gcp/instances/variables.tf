variable "machine_type" {
  type = map(string)
}

variable "zone" {
  type = string
}

variable "image" {
  type = string
}

variable "disk_size_gb" {
  type = map(number)
}

variable "disk_type" {
  type = map(string)
}

variable "number_control_planes" {
  type    = number
  default = 3
}

variable "number_workers" {
  type    = number
  default = 2
}

variable "instance_tags" {
  type = map(string)
  default = {
    bastion       = "bastion"
    control_plane = "control-plane"
    worker        = "worker"
  }
}

variable "network" {}

variable "subnetworks" {
  type = map(any)
  default = {
    "bastion"       = null
    "control_plane" = null
    "worker"        = null
  }
}

variable "region" {
  type = string
}

variable "ssh_user" {
  type = string
}

variable "ssh_pub_key_file" {
  type = string
}

variable "nfs_disk" {}

variable "http_ingress_nodeport" {
  type = string
}
