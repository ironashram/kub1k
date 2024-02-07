# initialize an empty local kubeconfig file
resource "local_sensitive_file" "kubeconfig" {
  content  = "---"
  filename = local.kube_config_output
  lifecycle {
    ignore_changes = [content]
  }
}

