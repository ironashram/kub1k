/*********
  CoreDNS
*********/

resource "helm_release" "coredns" {
  name = yamldecode(file("${path.module}/manifests/coredns.yaml")).metadata.name

  repository = yamldecode(file("${path.module}/manifests/coredns.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/coredns.yaml")).spec.source.chart
  version    = yamldecode(file("${path.module}/manifests/coredns.yaml")).spec.source.targetRevision
  namespace  = yamldecode(file("${path.module}/manifests/coredns.yaml")).metadata.namespace

  create_namespace = true

  max_history = 0

  set {
    name  = "service.clusterIP"
    value = var.k3s_cluster_dns
  }

  values = [
    file("${path.module}/values/coredns.yaml"),
  ]
}
