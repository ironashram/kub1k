resource "helm_release" "argocd_app_of_apps" {
  depends_on = [helm_release.argocd]

  name      = "argocd-app-of-apps"
  chart     = "${path.root}/../charts/argocd-app-of-apps"
  namespace = "argocd"

  create_namespace = true

  set_sensitive {
    name  = "environment"
    value = terraform.workspace
  }

  set_sensitive {
    name  = "internalDomain"
    value = var.internal_domain
  }

  set_sensitive {
    name  = "externalDomain"
    value = var.external_domain
  }

  set_sensitive {
    name  = "k8sEndpoint"
    value = var.k8s_endpoint
  }

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
