variable "network_name" {
  description = "The name of the network"
  type = string
}

variable "subnetwork_name" {
  description = "A map of subnetwork names with their types"
  type        = map(string)
}

variable "ip_cidr_range" {
  description = "A map of subnetwork IP CIDR ranges with their types"
  type        = map(string)
}

variable "region" {
  description = "The region where the network will be created"
  type = string
}
