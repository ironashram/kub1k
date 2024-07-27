/*********
  Cilium
*********/

resource "helm_release" "cilium" {
  name = "cilium"

  repository = "https://helm.cilium.io/"
  chart      = "cilium"
  version    = "1.16.0"
  namespace  = "kube-system"

  create_namespace = true

  max_history = 0

  values = [<<EOF
k8sServiceHost: 10.0.0.241
k8sServicePort: 6443
kubeProxyReplacement: true
l2announcements:
  enabled: true
externalIPs:
  enabled: true
ipam:
  operator:
    clusterPoolIPv4PodCIDRList: ["172.27.0.0/21"]
    clusterPoolIPv4MaskSize: 24
hubble:
  relay:
    enabled: true
  ui:
    enabled: true
    ingress:
      annotations:
        cert-manager.io/cluster-issuer: letsencrypt-prod
      enabled: true
      className: nginx
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
