output "kubeconfig" {
  value     = yamldecode(file(var.kube_config_output))
  sensitive = true
}
