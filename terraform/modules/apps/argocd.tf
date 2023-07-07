/****************
  ArgoCD values
****************/

data "template_file" "argocd_values" {
  template = <<EOF
applicationSet:
  enabled: false
global:
  image:
    tag: "v2.7.7"
redis-ha:
  enabled: false
dex:
  enabled: false
notifications:
  enabled: false
configs:
  repositories:
    k3s-ygg:
      url: ${var.git_repo}
      name: ${var.git_repo_name}
      type: git
      password: ${var.git_token}
      username: ${var.git_user}
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
    annotations:
      cert-manager.io/cluster-issuer: letsencrypt-prod
    ingressClassName: nginx
    enabled: true
    hosts:
    - ${var.argocd_hostname}
    https: true
    tls:
     - secretName: argocd-cert
       hosts:
       - ${var.argocd_hostname}
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
  version    = "5.37.1"

  create_namespace = true

  max_history = 0

  values = [data.template_file.argocd_values.rendered]
}
