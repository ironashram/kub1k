module "provision_k3s" {
  source = "./modules/k3s"

  control_nodes      = local.control_nodes
  worker_nodes       = local.worker_nodes
  k3s_extra_args     = local.k3s_extra_args
  k3s_version        = var.k3s_version
  kube_config_output = local.kube_config_output
  ssh_user           = data.vault_kv_secret_v2.ssh.data.user
}
