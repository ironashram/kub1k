/*****************
  Provision K3S
*****************/
module "provision_k3s" {
  source = "./modules/k3s"

  control            = var.control
  worker             = var.worker
  k3s_extra_args     = var.k3s_extra_args
  k3s_version        = var.k3s_version
  kube_context       = var.kube_context
  kube_config_output = local.kube_config_output
  ssh_user           = data.vault_kv_secret_v2.ssh.data.user
  ssh_key_file       = data.vault_kv_secret_v2.ssh.data.key_file

}
