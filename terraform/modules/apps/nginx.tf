/****************
  Nginx values
****************/

data "template_file" "nginx_values" {
  template = <<EOF
controller:
  config:
    entries:
      force-ssl-redirect: "true"
      ssl-redirect: "true"
      hsts: "true"
  ingressClassResource:
    name: nginx
    enabled: true
    default: false
    controllerValue: "k8s.io/ingress-nginx"
EOF
}

/*********
  Nginx
*********/

resource "helm_release" "nginx_ingress" {
  depends_on = [helm_release.tigera_operator]
  name       = "nginx-ingress"

  repository = "https://helm.nginx.com/stable"
  chart      = "nginx-ingress"
  version    = "0.18.0"
  namespace  = "nginx-ingress"

  create_namespace = true

  max_history = 0

  values = [data.template_file.nginx_values.rendered]
}
