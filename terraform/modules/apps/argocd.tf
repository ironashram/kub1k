/*********
  ArgoCD
*********/
resource "helm_release" "argocd" {
  depends_on       = [helm_release.cilium, helm_release.cert_manager, helm_release.haproxy_ingress, helm_release.coredns]
  name             = yamldecode(file("${path.module}/manifests/argocd.yaml")).metadata.name
  repository       = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.repoURL
  chart            = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.chart
  namespace        = yamldecode(file("${path.module}/manifests/argocd.yaml")).metadata.namespace
  version          = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.targetRevision
  disable_webhooks = false

  create_namespace = true

  max_history = 0

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = var.argocd_admin_password
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.name"
    value = var.git_repo_name
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.url"
    value = var.git_repo
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.username"
    value = var.git_user
  }

  set_sensitive {
    name  = "configs.repositories.${terraform.workspace}.password"
    value = var.git_token
  }

  set {
    name  = "configs.repositories.${terraform.workspace}.type"
    value = "git"
  }

  values = [<<EOF
global:
  domain: argocd.lab.m1k.cloud
redis:
  enabled: true
  metrics:
    enabled: false
redis-ha:
  enabled: false
redisSecretInit:
  enabled: true
dex:
  enabled: false
notifications:
  enabled: false
configs:
  cm:
    application.resourceTrackingMethod: annotation
  params:
    server.insecure: true
controller:
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
repoServer:
  replicas: 1
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
server:
  replicas: 1
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
  ingress:
    enabled: true
    ingressClassName: haproxy
    tls: true
  certificate:
    enabled: true
    issuer:
      group: cert-manager.io
      kind: ClusterIssuer
      name: letsencrypt-prod
EOF
  ]
}
