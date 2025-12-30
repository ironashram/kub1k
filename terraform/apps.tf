module "provision_apps" {
  count  = local.cluster_host != null ? 1 : 0
  source = "./modules/apps"

  argocd_admin_password = data.vault_generic_secret.argocd.data["admin_password"]
  vault_token           = data.vault_generic_secret.vault.data["token"]
  git_token             = data.vault_generic_secret.github.data["token"]
  git_user              = data.vault_generic_secret.github.data["username"]
  git_repo              = data.vault_generic_secret.github.data["repo"]
  git_repo_name         = data.vault_generic_secret.github.data["repo_name"]
  internal_domain       = data.vault_generic_secret.domain.data["internal"]
  external_domain       = data.vault_generic_secret.domain.data["external"]
  k3s_cluster_dns       = var.k3s_cluster_dns
  k8s_endpoint          = local.control_mgmt_ips[0]
  worker_names          = local.worker_names
  lb_pool_cidr          = var.lb_pool_cidr
  cluster_name          = var.cluster_name

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
