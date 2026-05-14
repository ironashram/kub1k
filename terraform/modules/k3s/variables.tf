variable "ssh_user" {}

variable "kube_config_output" {}

variable "k3s_extra_args" {}

variable "k3s_server_join_args" {}

variable "k3s_version" {}

variable "k3s_install_script_url" {}

variable "control_mgmt_ips" {}

variable "control_names" {}

variable "worker_mgmt_ips" {}

variable "worker_names" {}

variable "cluster_name" {}

variable "control_plane_vip" {}

variable "apiserver_auth_config_yaml" {
  description = "Contents of /etc/rancher/k3s/auth-config.yaml (kube-apiserver structured AuthenticationConfiguration)."
  type        = string
}
