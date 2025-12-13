module "provision_k3s" {
  source     = "./modules/k3s"
  depends_on = [synology_virtualization_guest.worker_nodes, synology_virtualization_guest.control_nodes]

  control_mgmt_ips   = local.control_mgmt_ips
  worker_mgmt_ips    = local.worker_mgmt_ips
  control_names      = local.control_names
  worker_names       = local.worker_names
  k3s_extra_args     = local.k3s_extra_args
  k3s_version        = var.k3s_version
  kube_config_output = local.kube_config_output
  ssh_user           = ephemeral.vault_kv_secret_v2.ssh.data.user
  cluster_name       = var.cluster_name
}
