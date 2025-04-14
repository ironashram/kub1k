resource "helm_release" "cert_manager" {
  depends_on = [helm_release.cilium]
  name       = yamldecode(file("${path.module}/manifests/cert-manager.yaml")).metadata.name

  repository = yamldecode(file("${path.module}/manifests/cert-manager.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/cert-manager.yaml")).spec.source.chart
  version    = yamldecode(file("${path.module}/manifests/cert-manager.yaml")).spec.source.targetRevision
  namespace  = yamldecode(file("${path.module}/manifests/cert-manager.yaml")).metadata.namespace

  create_namespace = true

  max_history = 0

  set {
    name  = "crds.enabled"
    value = "true"
  }
}

resource "helm_release" "webhook_hetzner" {
  depends_on = [helm_release.cert_manager]
  name       = yamldecode(file("${path.module}/manifests/webhook-hetzner.yaml")).metadata.name

  repository = yamldecode(file("${path.module}/manifests/webhook-hetzner.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/webhook-hetzner.yaml")).spec.source.chart
  version    = yamldecode(file("${path.module}/manifests/webhook-hetzner.yaml")).spec.source.targetRevision
  namespace  = yamldecode(file("${path.module}/manifests/webhook-hetzner.yaml")).metadata.namespace

  max_history = 0

  set {
    name  = "groupName"
    value = "acme.${var.external_domain}"
  }

  set_list {
    name = "secretName"
    value = [
      "hetzner-cloud-token"
    ]
  }
}
