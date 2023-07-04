/****************
  Calico values
****************/

data "template_file" "calico_values" {
  template = <<EOF
installation:
  # Configures Calico networking.
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: 192.168.0.0/21
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
EOF
}

/*********
  Calico
*********/

resource "helm_release" "tigera-operator" {
  name = "tigera-operator"

  repository = "https://docs.projectcalico.org/charts"
  chart      = "tigera-operator"
  version    = "v3.26.1"
  namespace  = "tigera-operator"

  create_namespace = true

  max_history = 10

  values = [data.template_file.calico_values.rendered]
}
