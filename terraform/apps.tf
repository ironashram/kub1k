/*****************
  Provision Apps
*****************/
module "provision_apps" {
  source = "./modules/apps"

  argocd_hostname = data.vault_kv_secret_v2.argocd.data.hostname
  vault_token     = data.vault_kv_secret_v2.vault.data.token
  git_token       = data.vault_kv_secret_v2.github.data.token
  git_user        = data.vault_kv_secret_v2.github.data.username
  git_repo        = data.vault_kv_secret_v2.github.data.repo
  git_repo_name   = data.vault_kv_secret_v2.github.data.repo_name
  kubeconfig      = module.provision_k3s.kubeconfig
}
