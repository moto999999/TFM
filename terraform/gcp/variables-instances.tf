variable "machine_type" {
  type = map(any)
  default = {
    control_plane = "e2-standard-2"
    worker        = "e2-standard-2"
    bastion       = "e2-medium"
  }
}

variable "disk_type" {
  type = map(any)
  default = {
    balanced = "pd-standard"
    ssd      = "pd-ssd"
  }
}

variable "disk_size_gb" {
  type = map(any)
  default = {
    control_plane = "50"
    worker        = "50"
    bastion       = "25"
  }
}

variable "disk_size_nfs" {
  type    = string
  default = "100"
}

variable "image" {
  type    = string
  default = "rocky-linux-9-optimized-gcp-v20230411"
}

variable "ssh_user" {
  type    = string
  default = "admin"
}

variable "ssh_pub_key_file" {
  type    = string
  default = "../../ssh_key/admin.pub"
}

variable "number_control_planes" {
  type    = number
  default = 3
}

variable "number_workers" {
  type    = number
  default = 2
}

variable "certificate" {
  type    = string
  default = "../../certificates/server.crt"
}

variable "certificate_private_key" {
  type    = string
  default = "../../certificates/server.key"
}
