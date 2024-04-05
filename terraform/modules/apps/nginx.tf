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
EOF
}

/*********
  Nginx
*********/

resource "helm_release" "ingress_nginx" {
  depends_on = [helm_release.tigera_operator]
  name       = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"
  namespace  = "ingress-nginx"

  create_namespace = true

  max_history = 0

  values = [data.template_file.nginx_values.rendered]
}
