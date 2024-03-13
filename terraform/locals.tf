locals {
  kube_config_output = pathexpand("~/.kube/config-files/${terraform.workspace}.yaml")

  // decode base64 kubeconfig from vault
  kubeconfig             = try(yamldecode(base64decode(data.vault_kv_secret_v2.k3s.data.kubeconfig)), null)
  cluster_host           = try(local.kubeconfig.clusters[0].cluster.server, null)
  cluster_ca_certificate = try(base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data), null)
  client_certificate     = try(base64decode(local.kubeconfig.users[0].user.client-certificate-data), null)
  client_key             = try(base64decode(local.kubeconfig.users[0].user.client-key-data), null)
}
