locals {
  kube_vip_app = yamldecode(file("${path.root}/../apps/templates/kube-vip.yaml"))
}

resource "helm_release" "kube_vip" {
  depends_on = [helm_release.calico]

  name             = local.kube_vip_app.metadata.name
  repository       = local.kube_vip_app.spec.source.repoURL
  chart            = local.kube_vip_app.spec.source.chart
  version          = local.kube_vip_app.spec.source.targetRevision
  namespace        = local.kube_vip_app.spec.destination.namespace
  create_namespace = true

  values = [
    yamlencode(local.kube_vip_app.spec.source.helm.valuesObject),
    yamlencode({
      config = {
        address = var.control_plane_vip
      }
    }),
  ]

  lifecycle {
    ignore_changes = all
  }
}
