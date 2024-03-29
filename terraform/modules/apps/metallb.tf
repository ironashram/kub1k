/*********
  MetalLB
*********/

resource "helm_release" "metallb_ingress" {
  depends_on = [helm_release.tigera_operator]
  name       = "metallb"

  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.14.3"
  namespace  = "metallb-system"

  create_namespace = true

  max_history = 0
}
