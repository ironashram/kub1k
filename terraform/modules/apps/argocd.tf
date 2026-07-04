locals {
  argocd_app = yamldecode(file("${path.root}/../apps/templates/argocd.yaml"))

  argocd_values = replace(
    replace(
      replace(
        yamlencode(local.argocd_app.spec.source.helm.valuesObject),
        "{{ .Values.internalDomain }}", var.internal_domain
      ),
      "{{ .Values.externalDomain }}", var.external_domain
    ),
    "{{ .Values.keycloakRealmId }}", var.keycloak_realm_id
  )
}

resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    name = local.argocd_app.spec.destination.namespace
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations, metadata[0].labels]
  }
}

resource "kubernetes_secret_v1" "argocd_secret" {
  depends_on = [kubernetes_namespace_v1.argocd]

  metadata {
    name      = "argocd-secret"
    namespace = local.argocd_app.spec.destination.namespace
    labels = {
      "app.kubernetes.io/name"    = "argocd-secret"
      "app.kubernetes.io/part-of" = "argocd"
    }
  }

  data = {
    "admin.password" = var.argocd_admin_password
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = all
  }
}

resource "kubernetes_secret_v1" "argocd_repo" {
  depends_on = [kubernetes_namespace_v1.argocd]

  metadata {
    name      = "argocd-repo-${var.cluster_name}"
    namespace = local.argocd_app.spec.destination.namespace
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = var.git_repo
    name     = var.git_repo_name
    username = var.git_user
    password = var.git_token
  }

  type = "Opaque"

  lifecycle {
    ignore_changes = all
  }
}

resource "helm_release" "argocd" {
  depends_on = [
    helm_release.coredns,
    kubernetes_secret_v1.argocd_secret,
    kubernetes_secret_v1.argocd_repo,
  ]

  name             = local.argocd_app.metadata.name
  repository       = local.argocd_app.spec.source.repoURL
  chart            = local.argocd_app.spec.source.chart
  namespace        = local.argocd_app.spec.destination.namespace
  version          = local.argocd_app.spec.source.targetRevision
  disable_webhooks = false

  max_history = 0

  values = [
    local.argocd_values,
  ]

  lifecycle {
    ignore_changes = all
  }
}
