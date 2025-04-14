resource "helm_release" "haproxy_ingress" {
  depends_on = [helm_release.cilium, helm_release.cert_manager]
  name       = yamldecode(file("${path.module}/manifests/haproxy-ingress.yaml")).metadata.name

  repository = yamldecode(file("${path.module}/manifests/haproxy-ingress.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/haproxy-ingress.yaml")).spec.source.chart
  version    = yamldecode(file("${path.module}/manifests/haproxy-ingress.yaml")).spec.source.targetRevision
  namespace  = yamldecode(file("${path.module}/manifests/haproxy-ingress.yaml")).metadata.namespace

  create_namespace = true

  max_history = 0

  values = [
    file("${path.module}/values/haproxy-ingress.yaml"),
  ]
}
