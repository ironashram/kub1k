resource "helm_release" "calico" {

  name       = yamldecode(file("${path.module}/manifests/calico.yaml")).metadata.name
  repository = yamldecode(file("${path.module}/manifests/calico.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/calico.yaml")).spec.source.chart
  namespace  = yamldecode(file("${path.module}/manifests/calico.yaml")).spec.destination.namespace
  version    = yamldecode(file("${path.module}/manifests/calico.yaml")).spec.source.targetRevision

  create_namespace = true

  max_history = 0

  values = [
    file("${path.module}/values/calico.yaml"),
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }

}
