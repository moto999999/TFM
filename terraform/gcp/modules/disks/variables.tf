variable "zone" {
  type = string
}

variable "region" {
  type = string
}

variable "disk_type" {
  type = map(string)
}

variable "disk_size_gb" {
  type = string
}
