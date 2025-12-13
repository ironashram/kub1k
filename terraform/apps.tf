module "provision_apps" {
  count  = local.cluster_host != null ? 1 : 0
  source = "./modules/apps"

  argocd_admin_password = ephemeral.vault_kv_secret_v2.argocd.data.admin_password
  vault_token           = ephemeral.vault_kv_secret_v2.vault.data.token
  git_token             = ephemeral.vault_kv_secret_v2.github.data.token
  git_user              = ephemeral.vault_kv_secret_v2.github.data.username
  git_repo              = ephemeral.vault_kv_secret_v2.github.data.repo
  git_repo_name         = ephemeral.vault_kv_secret_v2.github.data.repo_name
  internal_domain       = ephemeral.vault_kv_secret_v2.domain.data.internal
  external_domain       = ephemeral.vault_kv_secret_v2.domain.data.external
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
