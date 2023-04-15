variable "instance_tags" {
  type = map(string)
  default = {
    bastion       = "bastion"
    control_plane = "control-plane"
    worker        = "worker"
  }
}
