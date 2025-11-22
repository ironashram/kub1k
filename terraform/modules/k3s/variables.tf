variable "ssh_user" {
  ephemeral = true
}

variable "kube_config_output" {}

variable "k3s_extra_args" {}

variable "k3s_version" {}

variable "control_nodes" {}

variable "worker_nodes" {}
