locals {
  coredns_app = yamldecode(file("${path.root}/../apps/templates/coredns.yaml"))
}

resource "helm_release" "coredns" {
  depends_on = [helm_release.calico]
  name       = local.coredns_app.metadata.name

  repository = local.coredns_app.spec.source.repoURL
  chart      = local.coredns_app.spec.source.chart
  version    = local.coredns_app.spec.source.targetRevision
  namespace  = local.coredns_app.spec.destination.namespace

  create_namespace = true

  max_history = 0

  set_sensitive = [{
    name  = "service.clusterIP"
    value = var.k3s_cluster_dns
  }]

  values = [
    yamlencode(local.coredns_app.spec.source.helm.valuesObject),
  ]

  lifecycle {
    ignore_changes = all
  }
}
