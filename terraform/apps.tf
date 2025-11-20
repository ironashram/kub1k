module "provision_apps" {
  count  = local.cluster_host != null ? 1 : 0
  source = "./modules/apps"

  argocd_admin_password = ephemeral.vault_kv_secret_v2.argocd.data.admin_password
  vault_token           = ephemeral.vault_kv_secret_v2.vault
  git_token             = ephemeral.vault_kv_secret_v2.github.data.token
  git_user              = ephemeral.vault_kv_secret_v2.github.data.username
  git_repo              = ephemeral.vault_kv_secret_v2.github.data.repo
  git_repo_name         = ephemeral.vault_kv_secret_v2.github.data.repo_name
  internal_domain       = ephemeral.vault_kv_secret_v2.domain.data.internal
  external_domain       = ephemeral.vault_kv_secret_v2.domain.data.external
  k3s_cluster_dns       = var.k3s_cluster_dns
  k8s_endpoint          = local.control_nodes[0].ip
  worker_nodes          = local.worker_nodes
  lb_pool_cidr          = var.lb_pool_cidr
  write_only_revision   = var.write_only_revision

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}
