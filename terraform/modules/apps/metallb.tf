/****************
  MetalLB values
****************/

data "template_file" "metallb_values" {
  template = <<EOF
EOF
}

/*********
  MetalLB
*********/

resource "helm_release" "metallb_ingress" {
  depends_on = [helm_release.tigera_operator]
  name       = "metallb"

  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"
  version    = "0.13.10"
  namespace  = "metallb-system"

  create_namespace = true

  max_history = 0

  values = [data.template_file.metallb_values.rendered]
}
