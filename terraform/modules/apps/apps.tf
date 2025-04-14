resource "helm_release" "argocd_app_of_apps" {
  depends_on = [helm_release.argocd]

  name      = "argocd-app-of-apps"
  chart     = "${path.root}/../charts/argocd-app-of-apps"
  namespace = "argocd"

  create_namespace = true

  set {
    name  = "environment"
    value = terraform.workspace
  }

  set {
    name  = "internalDomain"
    value = var.internal_domain
  }

  set {
    name  = "externalDomain"
    value = var.external_domain
  }
}
