resource "helm_release" "kube_vip" {
  depends_on = [helm_release.calico]

  name             = yamldecode(file("${path.module}/manifests/kube-vip.yaml")).metadata.name
  repository       = yamldecode(file("${path.module}/manifests/kube-vip.yaml")).spec.source.repoURL
  chart            = yamldecode(file("${path.module}/manifests/kube-vip.yaml")).spec.source.chart
  version          = yamldecode(file("${path.module}/manifests/kube-vip.yaml")).spec.source.targetRevision
  namespace        = yamldecode(file("${path.module}/manifests/kube-vip.yaml")).spec.destination.namespace
  create_namespace = true

  values = [
    yamlencode({
      config = {
        address = var.control_plane_vip
      }
      env = {
        vip_interface           = "eth0"
        vip_arp                 = "true"
        cp_enable               = "true"
        vip_leaderelection      = "true"
        vip_leasename           = "plndr-cp-lock"
        lb_enable               = "false"
        svc_enable              = "false"
        lb_port                 = "6443"
        KUBERNETES_SERVICE_HOST = "127.0.0.1"
        KUBERNETES_SERVICE_PORT = "6443"
      }
      nodeSelector = {
        "node-role.kubernetes.io/control-plane" = "true"
      }
    })
  ]
}
