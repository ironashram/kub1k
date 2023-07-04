locals {
  kubeconfig = try(
    yamldecode(file("${path.root}/../environments/${terraform.workspace}/kubeconfig")),
    yamldecode(var.kubeconfig)
  )
  cluster_host           = local.kubeconfig.clusters[0].cluster.server
  cluster_ca_certificate = base64decode(local.kubeconfig.clusters[0].cluster.certificate-authority-data)
  client_certificate     = base64decode(local.kubeconfig.users[0].user.client-certificate-data)
  client_key             = base64decode(local.kubeconfig.users[0].user.client-key-data)
}
