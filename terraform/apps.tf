/*****************
  Provision Apps
*****************/
module "provision_apps" {
  count  = local.cluster_host != null ? 1 : 0
  source = "./modules/apps"

  argocd_admin_password = data.vault_kv_secret_v2.argocd.data.admin_password
  vault_token           = data.vault_kv_secret_v2.vault.data.token
  git_token             = data.vault_kv_secret_v2.github.data.token
  git_user              = data.vault_kv_secret_v2.github.data.username
  git_repo              = data.vault_kv_secret_v2.github.data.repo
  git_repo_name         = data.vault_kv_secret_v2.github.data.repo_name
  k3s_cluster_dns       = var.k3s_cluster_dns

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
