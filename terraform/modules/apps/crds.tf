resource "helm_release" "crds" {

  name              = "crds"
  chart             = "${path.root}/../charts/crds"
  namespace         = "default"
  dependency_update = true

}

locals {
  calico_version = yamldecode(file("${path.module}/manifests/calico.yaml")).spec.source.targetRevision
}

data "http" "calico_crd_url" {
  url = "https://raw.githubusercontent.com/projectcalico/calico/v${local.calico_version}/manifests/operator-crds.yaml"
}

resource "kubectl_manifest" "calico_crds" {
  yaml_body = data.http.calico_crd_url.response_body
}
