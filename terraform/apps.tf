/*****************
  Provision Apps
*****************/
module "provision_apps" {
  source = "./modules/apps"

  argocd_hostname = var.argocd_hostname
  kubeconfig      = var.kube_config_output
  vault_token     = var.vault_token
  git_token       = data.vault_kv_secret_v2.git_token.data.token
  git_user        = data.vault_kv_secret_v2.git_user.data.username
  git_repo        = var.git_repo
  git_repo_name   = var.git_repo_name
}
