locals {
  calico_app     = yamldecode(file("${path.root}/../apps/templates/calico.yaml"))
  calico_version = local.calico_app.spec.source.targetRevision
}

data "http" "calico_crd_url" {
  url = "https://raw.githubusercontent.com/projectcalico/calico/v${local.calico_version}/manifests/operator-crds.yaml"
}

resource "kubectl_manifest" "calico_crds" {
  yaml_body = data.http.calico_crd_url.response_body
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
