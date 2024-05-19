/*********
  Calico
*********/

resource "helm_release" "tigera_operator" {
  name = "tigera-operator"

  repository = "https://docs.projectcalico.org/charts"
  chart      = "tigera-operator"
  version    = "v3.28.0"
  namespace  = "tigera-operator"

  create_namespace = true

  max_history = 0

  values = [<<EOF
installation:
  calicoNetwork:
    ipPools:
    - blockSize: 26
      cidr: 10.49.0.0/21
      encapsulation: VXLANCrossSubnet
      natOutgoing: Enabled
      nodeSelector: all()
EOF
  ]

  provisioner "local-exec" {
    command = "sleep 60"
  }
}
