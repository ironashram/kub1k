/*****************
  Provision Apps
*****************/
module "provision_apps" {
  source = "./modules/apps"

  argocd_hostname = var.argocd_hostname
  kubeconfig      = var.kube_config_output
}
