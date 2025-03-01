/*********
  Nginx
*********/

resource "helm_release" "ingress_nginx" {
  depends_on = [helm_release.cilium, helm_release.cert_manager]
  name       = yamldecode(file("${path.module}/manifests/nginx.yaml")).metadata.name

  repository = yamldecode(file("${path.module}/manifests/nginx.yaml")).spec.source.repoURL
  chart      = yamldecode(file("${path.module}/manifests/nginx.yaml")).spec.source.chart
  version    = yamldecode(file("${path.module}/manifests/nginx.yaml")).spec.source.targetRevision
  namespace  = yamldecode(file("${path.module}/manifests/nginx.yaml")).metadata.namespace

  create_namespace = true

  max_history = 0

  values = [data.template_file.nginx_values.rendered]
}

/****************
  Nginx values
****************/

data "template_file" "nginx_values" {
  template = <<EOF
controller:
  ingressClassResource:
    name: nginx
    enabled: true
    default: false
    controllerValue: "k8s.io/ingress-nginx"
  replicaCount: 2
  minAvailable: 1
admissionWebhooks:
  enabled: false
EOF
}
