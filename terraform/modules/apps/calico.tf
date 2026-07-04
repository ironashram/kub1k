locals {
  calico_app = yamldecode(file("${path.root}/../apps/templates/calico.yaml"))
}

resource "helm_release" "calico" {
  depends_on = [kubectl_manifest.calico_crds]

  name       = local.calico_app.metadata.name
  repository = local.calico_app.spec.source.repoURL
  chart      = local.calico_app.spec.source.chart
  namespace  = local.calico_app.spec.destination.namespace
  version    = local.calico_app.spec.source.targetRevision

  create_namespace = true

  max_history = 0

  values = [
    yamlencode(local.calico_app.spec.source.helm.valuesObject),
    yamlencode({
      kubernetesServiceEndpoint = {
        host = var.control_plane_vip
        port = "6443"
      }
    }),
  ]

  lifecycle {
    ignore_changes = all
  }

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
