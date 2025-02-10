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

  values = [data.template_file.coredns_values.rendered]
}

/****************
  CoreDNS Values
****************/

data "template_file" "coredns_values" {
  template = <<EOF
service:
  clusterIP: "10.43.0.10"
replicaCount: 3
podDisruptionBudget:
  minAvailable: 1
EOF
}
