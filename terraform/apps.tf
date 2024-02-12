/*****************
  Provision Apps
*****************/
module "provision_apps" {
  count  = local.cluster_host != null ? 1 : 0
  source = "./modules/apps"

  vault_token   = data.vault_kv_secret_v2.vault.data.token
  git_token     = data.vault_kv_secret_v2.github.data.token
  git_user      = data.vault_kv_secret_v2.github.data.username
  git_repo      = data.vault_kv_secret_v2.github.data.repo
  git_repo_name = data.vault_kv_secret_v2.github.data.repo_name

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
