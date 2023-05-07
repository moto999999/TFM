variable "zone" {
  description = "The zone to create the managed zone in."
  type        = string
}

variable "region" {
  description = "The region to create the disk policy in."
  type        = string
}

variable "k8s_lb" {}

variable "dns_name" {
  type = string
}

variable "dns_names" {
  type    = list(string)
}
