resource "helm_release" "argocd_app_of_apps" {
  depends_on = [helm_release.argocd]

  name      = "argocd-app-of-apps"
  chart     = "${path.root}/../charts/argocd-app-of-apps"
  namespace = "argocd"

  create_namespace = true

  set_sensitive = [
    {
      name  = "environment"
      value = terraform.workspace
    },

    {
      name  = "internalDomain"
      value = var.internal_domain
    },

    {
      name  = "externalDomain"
      value = var.external_domain
    },

    {
      name  = "k8sEndpoint"
      value = var.k8s_endpoint
    },

    {
      name  = "k8sClusterDNS"
      value = var.k3s_cluster_dns
    },

    {
      name  = "l2AnnouncementInterface"
      value = var.l2_interface
    },

    {
      name  = "lbIpPool"
      value = var.lb_pool_cidr
  }]

  lifecycle {
    replace_triggered_by = [null_resource.src_argocd_app_of_apps]
  }
}

data "archive_file" "argocd_app_of_apps" {

  type        = "zip"
  source_dir  = "${path.root}/../charts/argocd-app-of-apps"
  output_path = "${path.root}/.terraform/argocd-app-of-apps.zip"
}

resource "null_resource" "src_argocd_app_of_apps" {
  triggers = {
    src_sha = data.archive_file.argocd_app_of_apps.output_sha
  }
}
