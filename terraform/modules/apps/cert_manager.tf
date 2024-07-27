/*********
  Cert Manager
*********/

resource "helm_release" "cert_manager" {
  depends_on = [helm_release.cert_manager]
  name       = "cert-manager"

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.15.1"
  namespace  = "cert-manager"

  create_namespace = true

  max_history = 0

  values = [<<EOF
installCRDs: true
EOF
  ]
}
