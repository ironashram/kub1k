/*********
  ArgoCD
*********/
resource "helm_release" "argocd" {
  depends_on       = [helm_release.cilium, helm_release.cert_manager]
  name             = yamldecode(file("${path.module}/manifests/argocd.yaml")).metadata.name
  repository       = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.repoURL
  chart            = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.chart
  namespace        = yamldecode(file("${path.module}/manifests/argocd.yaml")).metadata.namespace
  version          = yamldecode(file("${path.module}/manifests/argocd.yaml")).spec.source.targetRevision
  disable_webhooks = true

  create_namespace = true

  max_history = 0

  values = [data.template_file.argocd_values.rendered]

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
}

/****************
  ArgoCD values
****************/

data "template_file" "argocd_values" {
  template = <<EOF
global:
  domain: argocd.lab.m1k.cloud
applicationSet:
  enabled: false
redis-ha:
  enabled: false
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
    tls: true
  certificate:
    enabled: true
    issuer:
      group: cert-manager.io
      kind: ClusterIssuer
      name: letsencrypt-prod
EOF
}
