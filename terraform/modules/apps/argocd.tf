resource "helm_release" "argocd" {
  depends_on       = [helm_release.coredns]
  name             = yamldecode(file("${path.module}/manifests/argocd.yaml")).metadata.name
  repository       = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.repoURL
  chart            = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.chart
  namespace        = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.destination.namespace
  version          = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.targetRevision
  disable_webhooks = false

  create_namespace = true

  max_history = 0

  set_wo = [{
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password
    },

    {
      name  = "configs.repositories.${terraform.workspace}.name"
      value = var.git_repo_name
    },

    {
      name  = "configs.repositories.${terraform.workspace}.url"
      value = var.git_repo
    },

    {
      name  = "configs.repositories.${terraform.workspace}.username"
      value = var.git_user
    },

    {
      name  = "configs.repositories.${terraform.workspace}.password"
      value = var.git_token
    },

    {
      name  = "configs.repositories.${terraform.workspace}.type"
      value = "git"
    },

    {
      name  = "global.domain"
      value = "argocd.${var.internal_domain}"
  }]

  set_wo_revision = var.write_only_revision

  values = [
    file("${path.module}/values/argocd.yaml"),
  ]

}
