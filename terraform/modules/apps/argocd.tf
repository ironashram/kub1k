/*********
  ArgoCD
*********/
resource "helm_release" "argocd" {
  depends_on = [helm_release.tigera_operator]
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "6.7.3"

  create_namespace = true

  max_history = 0

  values = [<<EOF
applicationSet:
  enabled: false
redis-ha:
  enabled: false
dex:
  enabled: false
notifications:
  enabled: false
configs:
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
  ]

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


