resource "helm_release" "calico" {
  depends_on = [kubectl_manifest.calico_crds]

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

data "kubectl_file_documents" "calico_monitoring" {
  content = file("${path.module}/values/calico_monitoring.yaml")
}

resource "kubectl_manifest" "calico_monitoring" {
  for_each  = data.kubectl_file_documents.calico_monitoring.manifests
  yaml_body = each.value
}
