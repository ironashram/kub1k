/*********
  Cilium
*********/

resource "helm_release" "cilium" {
  name = "cilium"

  repository = yamldecode(file("${path.module}/manifests/cilium.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/cilium.yaml")).spec.source.chart
  version    = yamldecode(file("${path.module}/manifests/cilium.yaml")).spec.source.targetRevision
  namespace  = yamldecode(file("${path.module}/manifests/cilium.yaml")).metadata.namespace

  create_namespace = true

  max_history = 0

  values = [<<EOF
k8sServiceHost: 10.0.0.241
k8sServicePort: 6443
kubeProxyReplacement: true
l2announcements:
  enabled: true
prometheus:
  metricsService: true
  enabled: true
  serviceMonitor:
    enabled: true
operator:
  prometheus:
    metricsService: true
    enabled: true
    serviceMonitor:
      enabled: true
externalIPs:
  enabled: true
ipam:
  operator:
    clusterPoolIPv4PodCIDRList: ["172.27.0.0/21"]
    clusterPoolIPv4MaskSize: 24
hubble:
  metrics:
    enabled:
      - dns
      - drop
      - flow
      - flows-to-world
      - httpV2:exemplars=true;labelsContext=source_ip,source_namespace,source_workload,destination_ip,destination_namespace,destination_workload,traffic_direction
      - icmp
      - kafka
      - policy
      - port-distribution
      - tcp
    enableOpenMetrics: true
    serviceMonitor:
      enabled: true
  relay:
    enabled: true
    prometheus:
      enabled: true
      serviceMonitor:
        enabled: true
  ui:
    enabled: true
    ingress:
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
      enabled: true
      className: haproxy
      hosts:
        - hubble.lab.m1k.cloud
      tls:
        - secretName: hubble-cert
          hosts:
          - hubble.lab.m1k.cloud
EOF
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}


/*******************
  Cilium Resources
*******************/

resource "kubernetes_manifest" "cilium_lb_pool" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "lb-pool"
    }
    spec = {
      blocks = [
        {
          cidr = "10.0.0.230/32"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "cilium_l2_policy" {
  manifest = {
    apiVersion = "cilium.io/v2alpha1"
    kind       = "CiliumL2AnnouncementPolicy"
    metadata = {
      name = "l2-policy"
    }
    spec = {
      externalIPs     = true
      loadBalancerIPs = true
      interfaces = [
        "ens3"
      ]
    }
  }
}
