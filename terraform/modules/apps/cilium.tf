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
kubeProxyReplacement: true
k8sServiceHost: 10.0.0.241
k8sServicePort: 6443
externalIPs:
  enabled: true
bpf:
  hostLegacyRouting: false
  masquerade: false
ipam:
  operator:
    clusterPoolIPv4PodCIDRList: ["172.27.0.0/21"]
    clusterPoolIPv4MaskSize: 24
ipv4NativeRoutingCIDR: "172.27.0.0/21"
routingMdde: "native"
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
          cidr = "10.0.0.231/32"
        }
      ]
    }
  }
}
