resource "helm_release" "cilium" {
  depends_on = [helm_release.crds, kubernetes_namespace.monitoring]
  name       = "cilium"

  repository = yamldecode(file("${path.module}/manifests/cilium.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/cilium.yaml")).spec.source.chart
  version    = yamldecode(file("${path.module}/manifests/cilium.yaml")).spec.source.targetRevision
  namespace  = yamldecode(file("${path.module}/manifests/cilium.yaml")).metadata.namespace

  create_namespace = true

  max_history = 0

  set {
    name  = "k8sServiceHost"
    value = var.k8s_endpoint
  }

  set_list {
    name = "hubble.ui.ingress.hosts"
    value = [
      "hubble.${var.internal_domain}",
    ]
  }

  set_list {
    name = "hubble.ui.ingress.tls[0].hosts"
    value = [
      "hubble.${var.internal_domain}",
    ]
  }

  values = [
    file("${path.module}/values/cilium.yaml"),
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations]
  }
}

resource "kubectl_manifest" "cilium_lb_pool" {
  depends_on = [helm_release.crds]
  yaml_body  = <<-EOT
    apiVersion: cilium.io/v2
    kind: CiliumLoadBalancerIPPool
    metadata:
      name: lb-pool
    spec:
      blocks:
        - cidr: "${var.lb_pool_cidr}"
  EOT
}

resource "kubectl_manifest" "cilium_l2_policy" {
  depends_on = [helm_release.crds]
  yaml_body  = <<-EOT
    apiVersion: cilium.io/v2alpha1
    kind: CiliumL2AnnouncementPolicy
    metadata:
      name: l2-policy
    spec:
      externalIPs: true
      loadBalancerIPs: true
      interfaces:
        - "${var.l2_interface}"
  EOT
}
