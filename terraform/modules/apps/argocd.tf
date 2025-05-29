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

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.name"
    value = var.git_repo_name
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.url"
    value = var.git_repo
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.username"
    value = var.git_user
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.password"
    value = var.git_token
  }

  set {
    name  = "configs.repositories.${terraform.workspace}.type"
    value = "git"
  }

  set_sensitive {
    name  = "global.domain"
    value = "argocd.${var.internal_domain}"
  }

  values = [
    file("${path.module}/values/argocd.yaml"),
  ]

}
