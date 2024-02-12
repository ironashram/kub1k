/****************
  ArgoCD values
****************/

data "template_file" "argocd_values" {
  template = <<EOF
applicationSet:
  enabled: false
redis-ha:
  enabled: false
dex:
  enabled: false
notifications:
  enabled: false
configs:
  repositories:
    kub1k:
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
  ingress:
    enabled: true
    ingressClassName: nginx
    hostname: argocd.lab.m1k.cloud
    tls: true
  certificate:
    enabled: true
    domain: argocd.lab.m1k.cloud
    issuer:
      group: cert-manager.io
      kind: ClusterIssuer
      name: letsencrypt-prod

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
  version    = "6.0.6"

  create_namespace = true

  max_history = 0

  values = [data.template_file.argocd_values.rendered]
}
