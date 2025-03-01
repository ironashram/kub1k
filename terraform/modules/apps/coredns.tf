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
deployment:
  enabled: true
service:
  clusterIP: "${var.k3s_cluster_dns}"
replicaCount: 3
podDisruptionBudget:
  minAvailable: 1
prometheus:
  service:
    enabled: true
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "9153"
  monitor:
    enabled: true
EOF
}
