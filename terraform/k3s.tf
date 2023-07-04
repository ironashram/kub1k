/*****************
  Provision K3S
*****************/
module "provision_k3s" {
  source = "./modules/k3s"

  masters            = var.masters
  workers            = var.workers
  kube_context       = var.kube_context
  kube_config_output = var.kube_config_output
  ssh_user           = var.ssh_user
  ssh_key_file       = var.ssh_key_file
  k3s_extra_args     = var.k3s_extra_args

}
