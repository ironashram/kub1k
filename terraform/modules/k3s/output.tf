output "kubeconfig" {
  depends_on = [null_resource.k3s_control]
  value      = yamldecode(file(var.kube_config_output))
}
