variable "dns_name" {
  type = string
  default = "k8s-tfm.tk."
}

variable "dns_names" {
  type = list(string)
  default = ["prometheus", "prometheus-alertmanager", "grafana", "minio", "minio-console"]
}