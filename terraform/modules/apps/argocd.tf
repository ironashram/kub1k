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
  enabled: false
dex:
  enabled: false
notifications:
  enabled: false
configs:
  repositories:
    k3s-ygg:
      url: https://github.com/ironashram/k3s-ygg
      name: k3s-ygg
      type: git
      password: ${var.github_token}
      username: sysdadmin@m1k.cloud
  params:
    server.insecure: true
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
    ingressClassName: nginx
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
  depends_on = [helm_release.tigera_operator]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "5.37.0"

  create_namespace = true

  max_history = 0

  values = [data.template_file.argocd_values.rendered]
}
