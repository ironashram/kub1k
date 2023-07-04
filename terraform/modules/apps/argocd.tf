/****************
  ArgoCD values
****************/

data "template_file" "argocd_values" {
  template = <<EOF
applicationSet:
  enabled: false
global:
  image:
    tag: "v2.7.6"
redis-ha:
  enabled: true
configs:
  repositories:
    k3s-ygg:
      url: https://github.com/ironashram/k3s-ygg
      name: k3s-ygg
      type: git
      password: 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
      username: sysdadmin@m1k.cloud
controller:
  enableStatefulSet: true
  metrics:
    enabled: true
repoServer:
  replicas: 1
  metrics:
    enabled: true
server:
  replicas: 1
  config:
    url: http://${var.argocd_hostname}
    timeout.reconciliation: 600s
  ingress:
    enabled: true
    hosts:
    - ${var.argocd_hostname}
    https: false
EOF
}

/*********
  ArgoCD
*********/
resource "helm_release" "argocd" {
  depends_on = [helm_release.tigera-operator]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.37.0"

  create_namespace = true

  values = [data.template_file.argocd_values.rendered]
}
